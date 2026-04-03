import AppKit
import ApplicationServices
import Foundation
import SuperboardCore

struct MacPasteExecutor {
    func paste(
        _ item: ClipboardItem,
        into targetApplication: NSRunningApplication?,
        useVirtualClipboard: Bool
    ) {
        let pasteboard = NSPasteboard.general
        let snapshot = useVirtualClipboard ? PasteboardSnapshot.capture(from: pasteboard) : nil

        pasteboard.clearContents()

        switch item.content {
        case .text(let value):
            pasteboard.setString(value, forType: .string)
        case .image(let data, _, _):
            pasteboard.setData(data, forType: .tiff)
        case .files(let urls):
            pasteboard.writeObjects(urls as [NSPasteboardWriting])
        }

        targetApplication?.activate(options: [])

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) {
            postPasteShortcut()

            if let snapshot {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                    snapshot.restore(into: pasteboard)
                }
            }
        }
    }

    private func postPasteShortcut() {
        let source = CGEventSource(stateID: .combinedSessionState)
        let down = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        down?.flags = .maskCommand
        let up = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }
}

private struct PasteboardSnapshot {
    private let items: [NSPasteboardItem]

    static func capture(from pasteboard: NSPasteboard) -> PasteboardSnapshot {
        let copied = (pasteboard.pasteboardItems ?? []).map { item -> NSPasteboardItem in
            let newItem = NSPasteboardItem()
            for type in item.types {
                if let data = item.data(forType: type) {
                    newItem.setData(data, forType: type)
                } else if let str = item.string(forType: type) {
                    newItem.setString(str, forType: type)
                }
            }
            return newItem
        }
        return PasteboardSnapshot(items: copied)
    }

    func restore(into pasteboard: NSPasteboard) {
        pasteboard.clearContents()
        pasteboard.writeObjects(items)
        DebugLog.write("PasteboardSnapshot: restored items=\(items.count)")
    }
}
