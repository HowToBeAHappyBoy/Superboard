public protocol HistoryStore: Sendable {
    func save(item: ClipboardItem) throws
    func recentItems() throws -> [ClipboardItem]
}
