import Foundation

public enum ClipboardContent: Codable, Equatable, Sendable {
    case text(String)
    case image(data: Data, width: Int, height: Int)
    case files([URL])
}
