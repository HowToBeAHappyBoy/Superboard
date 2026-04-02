import Foundation

public struct ClipboardItem: Codable, Equatable, Identifiable, Sendable {
    public let id: String
    public let workspaceId: String
    public let capturedAt: Date
    public let sourceAppID: String
    public let sourceAppName: String
    public let content: ClipboardContent
    public let fingerprint: String
    public let isSensitive: Bool

    public var previewText: String {
        ContentPreviewBuilder.makePreview(for: content)
    }

    public init(
        id: String,
        workspaceId: String,
        capturedAt: Date,
        sourceAppID: String,
        sourceAppName: String,
        content: ClipboardContent,
        fingerprint: String = UUID().uuidString,
        isSensitive: Bool = false
    ) {
        self.id = id
        self.workspaceId = workspaceId
        self.capturedAt = capturedAt
        self.sourceAppID = sourceAppID
        self.sourceAppName = sourceAppName
        self.content = content
        self.fingerprint = fingerprint
        self.isSensitive = isSensitive
    }
}
