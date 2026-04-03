import AppKit
import Combine

@MainActor
final class MenuBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let onOpenSettings: () -> Void
    private let settings: AppSettingsStore
    private var cancellables: Set<AnyCancellable> = []

    init(settings: AppSettingsStore, onOpenSettings: @escaping () -> Void) {
        self.settings = settings
        self.onOpenSettings = onOpenSettings
        statusItem.button?.title = ""
        statusItem.button?.image = MenuBarIcon.skateboardTemplateImage(pointSize: 18)
        statusItem.button?.imagePosition = .imageOnly

        rebuildMenu()
        bindSettings()
    }

    @objc private func openSettings() {
        onOpenSettings()
    }

    private func rebuildMenu() {
        let menu = NSMenu()
        let settingsItem = NSMenuItem(
            title: settings.localized("menu.settings"),
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(
            withTitle: settings.localized("menu.quit"),
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        statusItem.menu = menu
    }

    private func bindSettings() {
        settings.$appLanguage
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.rebuildMenu()
            }
            .store(in: &cancellables)
    }
}
