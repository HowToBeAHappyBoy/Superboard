import AppKit
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
    private let pasteExecutor = MacPasteExecutor()
    private let contextLocator = FocusedContextLocator()
    private let permissionManager = AccessibilityPermissionManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        permissionManager.requestIfNeeded()
        menuBarController = MenuBarController()
        let supportDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let storeURL = supportDirectory.appendingPathComponent("Superboard/history.json")
        try? FileManager.default.createDirectory(
            at: storeURL.deletingLastPathComponent(),
            withIntermediateDirectories: true,
            attributes: nil
        )
        let historyStore = FileHistoryStore(storageURL: storeURL, limit: 50)
        self.historyStore = historyStore
        clipboardWatcher = MacClipboardWatcher(historyStore: historyStore)
        clipboardWatcher?.start()
        hotKeyMonitor = GlobalHotKeyMonitor { [weak self] in
            self?.openPicker()
        }
        hotKeyMonitor?.register()
    }

    private func openPicker() {
        guard let historyStore else { return }
        let items = (try? historyStore.recentItems()) ?? []
        pickerSession.open(with: Array(items.prefix(10)))
        pickerController = PastePickerPanelController(
            session: pickerSession,
            onMoveSelection: { [weak self] offset in
                self?.pickerSession.moveSelection(by: offset)
            },
            onChoose: { [weak self] in
                self?.chooseCurrentItem()
            },
            onCancel: { [weak self] in
                self?.pickerController?.close()
            }
        )
        pickerController?.show(at: contextLocator.pickerOrigin())
    }

    private func chooseCurrentItem() {
        guard let item = pickerSession.chooseSelected() else { return }
        pasteExecutor.paste(item)
        pickerController?.close()
    }
}
