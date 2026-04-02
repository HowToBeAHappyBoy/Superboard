import AppKit
import SwiftUI
import SuperboardCore

@MainActor
final class PastePickerPanelController {
    private let panel: NSPanel
    private var eventMonitor: Any?

    init(
        session: PastePickerSession,
        onMoveSelection: @escaping (Int) -> Void,
        onChoose: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        panel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 360, height: 320),
            styleMask: [.nonactivatingPanel, .titled],
            backing: .buffered,
            defer: false
        )
        panel.contentView = NSHostingView(rootView: PastePickerView(session: session))
        panel.isFloatingPanel = true
        panel.level = .statusBar

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
    }

    func show(at origin: CGPoint) {
        panel.setFrameOrigin(origin)
        NSApp.activate(ignoringOtherApps: true)
        panel.makeKeyAndOrderFront(nil)
    }

    func close() {
        panel.close()
    }

    deinit {
        if let eventMonitor {
            NSEvent.removeMonitor(eventMonitor)
        }
    }
}
