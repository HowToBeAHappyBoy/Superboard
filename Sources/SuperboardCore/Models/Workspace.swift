public struct Workspace: Codable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let kind: Kind

    public enum Kind: String, Codable, Sendable {
        case local
        case personalCloud
        case shared
    }

    public init(id: String, name: String, kind: Kind) {
        self.id = id
        self.name = name
        self.kind = kind
    }

    public static let local = Workspace(id: "local-default", name: "Local", kind: .local)
}
