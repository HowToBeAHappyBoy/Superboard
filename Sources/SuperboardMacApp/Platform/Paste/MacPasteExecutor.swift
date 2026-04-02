import AppKit
import ApplicationServices
import SuperboardCore

struct MacPasteExecutor {
    func paste(_ item: ClipboardItem) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()

        switch item.content {
        case .text(let value):
            pasteboard.setString(value, forType: .string)
        case .image(let data, _, _):
            pasteboard.setData(data, forType: .tiff)
        case .files(let urls):
            pasteboard.writeObjects(urls as [NSPasteboardWriting])
        }

        let source = CGEventSource(stateID: .combinedSessionState)
        let down = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: true)
        down?.flags = .maskCommand
        let up = CGEvent(keyboardEventSource: source, virtualKey: 0x09, keyDown: false)
        up?.flags = .maskCommand
        down?.post(tap: .cghidEventTap)
        up?.post(tap: .cghidEventTap)
    }
}
