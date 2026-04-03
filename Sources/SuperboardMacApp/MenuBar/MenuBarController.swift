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

        rebuildMenu(bundle: settings.localizationBundle)
        bindSettings()
    }

    @objc private func openSettings() {
        onOpenSettings()
    }

    private func rebuildMenu(bundle: Bundle) {
        let menu = NSMenu()
        let settingsItem = NSMenuItem(
            title: L10n.tr("menu.settings", bundle: bundle),
            action: #selector(openSettings),
            keyEquivalent: ","
        )
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(
            withTitle: L10n.tr("menu.quit", bundle: bundle),
            action: #selector(NSApplication.terminate(_:)),
            keyEquivalent: "q"
        )
        statusItem.menu = menu
    }

    private func bindSettings() {
        settings.$appLanguage
            .removeDuplicates()
            .sink { [weak self] newLanguage in
                let resolved = LanguageResolver.resolve(newLanguage)
                let bundle = LocalizationBundle.bundle(for: resolved)
                self?.rebuildMenu(bundle: bundle)
            }
            .store(in: &cancellables)
    }
}
