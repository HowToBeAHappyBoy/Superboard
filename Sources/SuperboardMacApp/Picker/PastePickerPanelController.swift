import AppKit
import SwiftUI
import SuperboardCore

@MainActor
final class PastePickerPanelController {
    static let panelSize = CGSize(width: 280, height: 206)
    private static let animationOffset: CGFloat = 10

    private let panel: NSPanel
    private var eventMonitor: Any?
    private var globalMonitors: [Any] = []
    private let onCancel: () -> Void

    init(
        session: PastePickerSession,
        onMoveSelection: @escaping (Int) -> Void,
        onChoose: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onCancel = onCancel
        panel = NSPanel(
            contentRect: NSRect(origin: .zero, size: Self.panelSize),
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.contentView = NSHostingView(
            rootView: PastePickerView(
                session: session,
                onChoose: onChoose,
                onCancel: onCancel
            )
        )
        panel.isFloatingPanel = true
        panel.level = .statusBar
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = true
        panel.collectionBehavior = [.transient, .ignoresCycle]
        // Do not auto-hide on deactivate: this app is an accessory app and the panel may be shown
        // while another app remains active. We dismiss explicitly via outside-click/ESC.
        panel.hidesOnDeactivate = false

        eventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            switch event.keyCode {
            case 125:
                onMoveSelection(1)
                return nil
            case 126:
                onMoveSelection(-1)
                return nil
            case 36:
                onChoose()
                return nil
            case 53:
                onCancel()
                return nil
            default:
                return event
            }
        }

        // Click outside to dismiss without requiring the panel to become key.
        if let m1 = NSEvent.addGlobalMonitorForEvents(
            matching: [.leftMouseDown, .rightMouseDown],
            handler: { [weak self] _ in
            guard let self else { return }
            let point = NSEvent.mouseLocation
            if self.panel.isVisible && !self.panel.frame.contains(point) {
                DispatchQueue.main.async {
                    self.onCancel()
                }
            }
            }
        ) {
            globalMonitors.append(m1)
        }
    }

    func show(at origin: CGPoint) {
        // Briefly activate so the panel can receive key events; we restore focus on cancel/choose.
        NSApp.activate(ignoringOtherApps: true)

        panel.alphaValue = 0
        panel.setFrameOrigin(CGPoint(x: origin.x, y: origin.y - Self.animationOffset))
        panel.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.12
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            panel.animator().alphaValue = 1
            panel.animator().setFrameOrigin(origin)
        }
    }

    func close() {
        let origin = panel.frame.origin
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.10
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            panel.animator().alphaValue = 0
            panel.animator().setFrameOrigin(CGPoint(x: origin.x, y: origin.y - Self.animationOffset))
        } completionHandler: {
            self.panel.orderOut(nil)
            self.panel.alphaValue = 1
        }
    }

    deinit {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
        for monitor in globalMonitors {
            NSEvent.removeMonitor(monitor)
        }
    }
}
