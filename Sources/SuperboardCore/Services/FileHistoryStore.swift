import Foundation

public final class FileHistoryStore: HistoryStore, @unchecked Sendable {
    private let storageURL: URL
    private let limit: Int
    private let lock = NSLock()
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    public init(storageURL: URL, limit: Int) {
        self.storageURL = storageURL
        self.limit = max(0, limit)
    }

    public func save(item: ClipboardItem) throws {
        try lock.withLock {
            var items = try loadItems()
            items.removeAll { $0.fingerprint == item.fingerprint }
            items.append(item)
            try write(items: normalized(items))
        }
    }

    public func recentItems() throws -> [ClipboardItem] {
        try lock.withLock {
            try loadItems()
        }
    }

    private func loadItems() throws -> [ClipboardItem] {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return [] }
        let items = try decoder.decode([ClipboardItem].self, from: Data(contentsOf: storageURL))
        return normalized(items)
    }

    private func normalized(_ items: [ClipboardItem]) -> [ClipboardItem] {
        let sorted = items.sorted(by: { $0.capturedAt > $1.capturedAt })
        return Array(sorted.prefix(limit))
    }

    private func write(items: [ClipboardItem]) throws {
        let data = try encoder.encode(items)
        try data.write(to: storageURL, options: .atomic)
    }
}

private extension NSLock {
    func withLock<T>(_ body: () throws -> T) throws -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
