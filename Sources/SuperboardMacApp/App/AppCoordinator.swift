import AppKit
import Combine
import Foundation
import SuperboardCore

@MainActor
final class AppCoordinator: NSObject, NSApplicationDelegate {
    private var menuBarController: MenuBarController?
    private var clipboardWatcher: MacClipboardWatcher?
    private var historyStore: FileHistoryStore?
    private var hotKeyMonitor: GlobalHotKeyMonitor?
    private let pickerSession = PastePickerSession()
    private var pickerController: PastePickerPanelController?
    private var pasteTargetApplication: NSRunningApplication?
    private let pasteExecutor = MacPasteExecutor()
    private let contextLocator = FocusedContextLocator()
    private let permissionManager = AccessibilityPermissionManager()
    private let settings = AppSettingsStore()
    private var settingsWindowController: SettingsWindowController?
    private var cancellables: Set<AnyCancellable> = []

    func applicationDidFinishLaunching(_ notification: Notification) {
        DebugLog.reset()
        DebugLog.write("AppCoordinator: didFinishLaunching")
        permissionManager.requestIfNeeded()
        menuBarController = MenuBarController(onOpenSettings: { [weak self] in
            self?.openSettings()
        })

        if settings.launchAtLogin {
            LoginItemManager.setEnabled(true)
        }

        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let storeURL = supportDirectory.appendingPathComponent("Superboard/history.json")
        try? FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )

        let historyStore = FileHistoryStore(storageURL: storeURL, limit: settings.historyStoreLimit)
        self.historyStore = historyStore
        clipboardWatcher = MacClipboardWatcher(historyStore: historyStore)
        clipboardWatcher?.start()
        DebugLog.write("HistoryStore: start limit=\(settings.historyStoreLimit)")

        hotKeyMonitor = GlobalHotKeyMonitor(shortcut: settings.hotKeyShortcut) { [weak self] in
            DebugLog.write("HotKey: handler invoked")
            self?.openPicker()
        }
        hotKeyMonitor?.register()
        DebugLog.write("AppCoordinator: hotkey register() returned")

        bindSettings()
    }

    private func openPicker() {
        guard let historyStore else { return }
        if pickerController != nil {
            cancelPicker()
            return
        }

        if settingsWindowController?.window?.isVisible == true {
            DebugLog.write("Picker: hiding settings window")
            settingsWindowController?.window?.orderOut(nil)
        }

        // Prompt again here so the first hotkey use guides the user to grant Accessibility.
        permissionManager.requestIfNeeded()
        let frontmost = NSWorkspace.shared.frontmostApplication
        pasteTargetApplication = frontmost
        DebugLog.write(
            "Picker: frontmost bundle=\(frontmost?.bundleIdentifier ?? "nil") " +
            "pid=\(frontmost?.processIdentifier ?? -1) " +
            "selfPid=\(NSRunningApplication.current.processIdentifier)"
        )
        let items = (try? historyStore.recentItems()) ?? []
        DebugLog.write("Picker: openPicker items=\(items.count)")
        pickerSession.open(with: Array(items.prefix(settings.pickerDisplayLimit)))
        pickerController = PastePickerPanelController(
            session: pickerSession,
            onMoveSelection: { [weak self] offset in
                self?.pickerSession.moveSelection(by: offset)
            },
            onChoose: { [weak self] in
                self?.chooseCurrentItem()
            },
            onCancel: { [weak self] in
                self?.cancelPicker()
            }
        )
        let origin = contextLocator.pickerOrigin(
            panelSize: PastePickerPanelController.panelSize,
            preferredApplicationPID: pasteTargetApplication?.processIdentifier
        )
        DebugLog.write("Picker: show origin=\(Int(origin.x)),\(Int(origin.y))")
        pickerController?.show(at: origin)
    }

    private func chooseCurrentItem() {
        guard let item = pickerSession.chooseSelected() else { return }
        let targetApplication = pasteTargetApplication
        pasteTargetApplication = nil
        DebugLog.write("Picker: choose item=\(item.id)")
        pasteExecutor.paste(item, into: targetApplication, useVirtualClipboard: settings.useVirtualClipboard)
        pickerController?.close()
        pickerController = nil
    }

    private func cancelPicker() {
        let targetApplication = pasteTargetApplication
        pasteTargetApplication = nil
        DebugLog.write("Picker: cancel")
        pickerController?.close()
        pickerController = nil
        targetApplication?.activate(options: [])
    }

    private func openSettings() {
        if settingsWindowController == nil {
            settingsWindowController = SettingsWindowController(settings: settings)
        }
        NSApp.activate(ignoringOtherApps: true)
        settingsWindowController?.showWindow(nil)
        settingsWindowController?.window?.makeKeyAndOrderFront(nil)
    }

    private func bindSettings() {
        settings.$historyStoreLimit
            .removeDuplicates()
            .sink { [weak self] newLimit in
                guard let self, let historyStore = self.historyStore else { return }
                do {
                    try historyStore.updateLimit(newLimit)
                    DebugLog.write("HistoryStore: updated limit=\(newLimit)")
                } catch {
                    DebugLog.write("HistoryStore: updateLimit failed limit=\(newLimit) error=\(error)")
                }
            }
            .store(in: &cancellables)

        settings.$hotKeyShortcut
            .removeDuplicates()
            .sink { [weak self] shortcut in
                DebugLog.write("Settings: hotkey updated \(shortcut.displayString)")
                self?.hotKeyMonitor?.updateShortcut(shortcut)
            }
            .store(in: &cancellables)

        settings.$launchAtLogin
            .removeDuplicates()
            .sink { enabled in
                LoginItemManager.setEnabled(enabled)
            }
            .store(in: &cancellables)
    }
}
