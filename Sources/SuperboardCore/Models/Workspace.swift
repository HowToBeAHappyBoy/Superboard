public struct Workspace: Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let kind: Kind

    public enum Kind: String, Codable, Sendable {
        case local
        case personalCloud
        case shared
    }

    public static let local = Workspace(id: "local-default", name: "Local", kind: .local)
}
