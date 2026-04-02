import AppKit
import SuperboardCore

struct MacPasteboardReader {
    func readCurrentItem(from pasteboard: NSPasteboard = .general) -> ClipboardItem? {
        if let string = pasteboard.string(forType: .string), !string.isEmpty {
            return ClipboardItem(
                id: UUID().uuidString,
                workspaceId: Workspace.local.id,
                capturedAt: Date(),
                sourceAppID: NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "unknown",
                sourceAppName: NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown",
                content: .text(string),
                fingerprint: "text-\(string.hashValue)"
            )
        }

        if let tiff = pasteboard.data(forType: .tiff), let image = NSImage(data: tiff) {
            let size = image.size
            return ClipboardItem(
                id: UUID().uuidString,
                workspaceId: Workspace.local.id,
                capturedAt: Date(),
                sourceAppID: NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "unknown",
                sourceAppName: NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown",
                content: .image(data: tiff, width: Int(size.width), height: Int(size.height)),
                fingerprint: "image-\(tiff.hashValue)"
            )
        }

        if let objects = pasteboard.readObjects(forClasses: [NSURL.self]), !objects.isEmpty {
            let urls = objects.compactMap { $0 as? URL }
            return ClipboardItem(
                id: UUID().uuidString,
                workspaceId: Workspace.local.id,
                capturedAt: Date(),
                sourceAppID: NSWorkspace.shared.frontmostApplication?.bundleIdentifier ?? "unknown",
                sourceAppName: NSWorkspace.shared.frontmostApplication?.localizedName ?? "Unknown",
                content: .files(urls),
                fingerprint: "files-\(urls.map(\.path).joined(separator: "|").hashValue)"
            )
        }

        return nil
    }
}
