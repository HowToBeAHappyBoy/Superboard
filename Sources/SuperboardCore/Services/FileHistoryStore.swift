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
            var items = try recentItemsUnlocked()
            items.removeAll { $0.fingerprint == item.fingerprint }
            items.insert(item, at: 0)
            items.sort(by: { $0.capturedAt > $1.capturedAt })
            if items.count > limit {
                items = Array(items.prefix(limit))
            }
            let data = try encoder.encode(items)
            try data.write(to: storageURL, options: .atomic)
        }
    }

    public func recentItems() throws -> [ClipboardItem] {
        try lock.withLock {
            try recentItemsUnlocked()
        }
    }

    private func recentItemsUnlocked() throws -> [ClipboardItem] {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return [] }
        return try decoder.decode([ClipboardItem].self, from: Data(contentsOf: storageURL))
            .sorted(by: { $0.capturedAt > $1.capturedAt })
    }
}

private extension NSLock {
    func withLock<T>(_ body: () throws -> T) throws -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
