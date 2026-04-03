import ApplicationServices
import Carbon
import Foundation

final class GlobalHotKeyMonitor {
    private let handler: () -> Void
    private var shortcut: HotKeyShortcut = .default

    // Carbon hotkey (preferred)
    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?

    // Event tap fallback (requires Input Monitoring permission in many setups)
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    init(shortcut: HotKeyShortcut = .default, handler: @escaping () -> Void) {
        self.handler = handler
        self.shortcut = shortcut
    }

    func updateShortcut(_ shortcut: HotKeyShortcut) {
        self.shortcut = shortcut
        unregister()
        register()
    }

    func register() {
        NSLog("GlobalHotKeyMonitor: register() start")
        DebugLog.write("GlobalHotKeyMonitor: register() start")

        if registerWithCarbon() {
            NSLog("GlobalHotKeyMonitor: using Carbon hotkey")
            DebugLog.write("GlobalHotKeyMonitor: using Carbon hotkey")
            return
        }

        NSLog("GlobalHotKeyMonitor: Carbon hotkey unavailable, falling back to event tap")
        DebugLog.write("GlobalHotKeyMonitor: Carbon hotkey unavailable, falling back to event tap")
        let keyDownMask = CGEventMask(1 << CGEventType.keyDown.rawValue)
        let userData = Unmanaged.passUnretained(self).toOpaque()
        eventTap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: keyDownMask,
            callback: { _, type, event, userInfo in
                guard type == .keyDown, let userInfo else { return Unmanaged.passUnretained(event) }
                let monitor = Unmanaged<GlobalHotKeyMonitor>.fromOpaque(userInfo).takeUnretainedValue()
                let keyCode = event.getIntegerValueField(.keyboardEventKeycode)
                let flags = event.flags
                let matchesKey = keyCode == Int64(monitor.shortcut.keyCode)
                let hasCmd = flags.contains(.maskCommand)
                let hasShift = flags.contains(.maskShift)
                let hasOption = flags.contains(.maskAlternate)
                let hasControl = flags.contains(.maskControl)
                let matchesModifiers =
                    hasCmd == monitor.shortcut.command &&
                    hasShift == monitor.shortcut.shift &&
                    hasOption == monitor.shortcut.option &&
                    hasControl == monitor.shortcut.control

                if matchesKey && matchesModifiers {
                    DispatchQueue.main.async {
                        NSLog("GlobalHotKeyMonitor: hotkey fired")
                        DebugLog.write("GlobalHotKeyMonitor: event tap hotkey fired")
                        monitor.handler()
                    }
                    return nil
                }
                return Unmanaged.passUnretained(event)
            },
            userInfo: userData
        )

        guard let eventTap else {
            NSLog("GlobalHotKeyMonitor: CGEvent.tapCreate failed (permissions?)")
            DebugLog.write("GlobalHotKeyMonitor: CGEvent.tapCreate failed (permissions?)")
            return
        }

        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            CGEvent.tapEnable(tap: eventTap, enable: true)
        } else {
            NSLog("GlobalHotKeyMonitor: failed to create run loop source")
            DebugLog.write("GlobalHotKeyMonitor: failed to create run loop source")
        }
    }

    private func registerWithCarbon() -> Bool {
        let eventTarget = GetEventDispatcherTarget()
        var eventSpec = EventTypeSpec(
            eventClass: OSType(kEventClassKeyboard),
            eventKind: UInt32(kEventHotKeyPressed)
        )
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()

        let installStatus = InstallEventHandler(
            eventTarget,
            { _, event, userData in
                guard let userData, let event else { return noErr }
                let monitor = Unmanaged<GlobalHotKeyMonitor>
                    .fromOpaque(userData)
                    .takeUnretainedValue()
                var hotKeyID = EventHotKeyID()
                GetEventParameter(
                    event,
                    EventParamName(kEventParamDirectObject),
                    EventParamType(typeEventHotKeyID),
                    nil,
                    MemoryLayout<EventHotKeyID>.size,
                    nil,
                    &hotKeyID
                )
                if hotKeyID.id == 1 {
                    DispatchQueue.main.async {
                        NSLog("GlobalHotKeyMonitor: Carbon hotkey fired")
                        monitor.handler()
                    }
                }
                return noErr
            },
            1,
            &eventSpec,
            selfPointer,
            &handlerRef
        )
        if installStatus != noErr {
            NSLog("GlobalHotKeyMonitor: InstallEventHandler failed: %d", installStatus)
            DebugLog.write("GlobalHotKeyMonitor: InstallEventHandler failed: \(installStatus)")
            return false
        }

        let hotKeyID = EventHotKeyID(signature: OSType(0x53424F41), id: 1)
        var carbonModifiers: UInt32 = 0
        if shortcut.command { carbonModifiers |= UInt32(cmdKey) }
        if shortcut.shift { carbonModifiers |= UInt32(shiftKey) }
        if shortcut.option { carbonModifiers |= UInt32(optionKey) }
        if shortcut.control { carbonModifiers |= UInt32(controlKey) }
        let registerStatus = RegisterEventHotKey(
            UInt32(shortcut.keyCode),
            carbonModifiers,
            hotKeyID,
            eventTarget,
            0,
            &hotKeyRef
        )
        if registerStatus != noErr {
            NSLog("GlobalHotKeyMonitor: RegisterEventHotKey failed: %d", registerStatus)
            DebugLog.write("GlobalHotKeyMonitor: RegisterEventHotKey failed: \(registerStatus)")
            return false
        }

        return true
    }

    private func unregister() {
        if let hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        if let handlerRef {
            RemoveEventHandler(handlerRef)
            self.handlerRef = nil
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
            self.runLoopSource = nil
        }
        if let eventTap {
            CFMachPortInvalidate(eventTap)
            self.eventTap = nil
        }
    }

    deinit {
        unregister()
    }
}
