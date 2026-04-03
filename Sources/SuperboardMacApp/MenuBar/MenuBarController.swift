import AppKit

final class MenuBarController {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let onOpenSettings: () -> Void

    init(onOpenSettings: @escaping () -> Void) {
        self.onOpenSettings = onOpenSettings
        statusItem.button?.title = ""
        statusItem.button?.image = MenuBarIcon.skateboardTemplateImage(pointSize: 18)
        statusItem.button?.imagePosition = .imageOnly
        let menu = NSMenu()
        let settingsItem = NSMenuItem(title: "설정…", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Superboard", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        statusItem.menu = menu
    }

    @objc private func openSettings() {
        onOpenSettings()
    }
}
