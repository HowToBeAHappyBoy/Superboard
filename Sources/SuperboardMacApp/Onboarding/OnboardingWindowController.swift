import AppKit
import Combine
import SwiftUI

@MainActor
final class OnboardingWindowController: NSWindowController {
    private var cancellables: Set<AnyCancellable> = []

    init(settings: AppSettingsStore, onDone: @escaping () -> Void) {
        let view = OnboardingView(settings: settings, onDone: onDone)
        let hostingController = NSHostingController(rootView: view)

        let window = NSWindow(contentViewController: hostingController)
        window.title = settings.localized("onboarding.window.title")
        window.styleMask = [.titled, .closable]
        window.isReleasedWhenClosed = false
        window.titleVisibility = .hidden
        window.titlebarAppearsTransparent = true
        window.isMovableByWindowBackground = true
        window.setContentSize(NSSize(width: 560, height: 440))
        window.minSize = NSSize(width: 560, height: 440)
        window.center()

        super.init(window: window)

        settings.$appLanguage
            .removeDuplicates()
            .sink { [weak self, weak settings] _ in
                guard let self, let settings else { return }
                self.window?.title = settings.localized("onboarding.window.title")
            }
            .store(in: &cancellables)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

