import AppKit

@main
struct SuperboardApp {
    static func main() {
        let application = NSApplication.shared
        let delegate = AppCoordinator()
        application.delegate = delegate
        application.setActivationPolicy(.accessory)
        application.run()
    }
}
