import AppKit
import Combine
import SwiftUI

@MainActor
final class SettingsWindowController: NSWindowController {
    private var cancellables: Set<AnyCancellable> = []

    init(settings: AppSettingsStore) {
        let view = SettingsView(settings: settings)
        let hostingController = NSHostingController(rootView: view)

        let window = NSWindow(contentViewController: hostingController)
        window.title = L10n.tr("settings.window.title", bundle: settings.localizationBundle)
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.setContentSize(NSSize(width: 520, height: 420))
        window.minSize = NSSize(width: 520, height: 420)
        window.center()

        super.init(window: window)

        settings.$appLanguage
            .removeDuplicates()
            .sink { [weak self] newLanguage in
                let resolved = LanguageResolver.resolve(newLanguage)
                let bundle = LocalizationBundle.bundle(for: resolved)
                self?.window?.title = L10n.tr("settings.window.title", bundle: bundle)
            }
            .store(in: &cancellables)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
