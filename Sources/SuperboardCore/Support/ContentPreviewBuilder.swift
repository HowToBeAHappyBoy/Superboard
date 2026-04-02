import Foundation

enum ContentPreviewBuilder {
    static func makePreview(for content: ClipboardContent) -> String {
        switch content {
        case .text(let value):
            return value.split(separator: "\n", maxSplits: 1).first.map(String.init) ?? ""
        case .image(_, let width, let height):
            return "Image \(width)×\(height)"
        case .files(let urls):
            if urls.count == 1, let first = urls.first {
                return first.lastPathComponent
            }
            return "\(urls.count) files"
        }
    }
}
