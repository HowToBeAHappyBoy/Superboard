import Foundation

public final class FileHistoryStore: HistoryStore, @unchecked Sendable {
    private let storageURL: URL
    private let limit: Int
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private static let lockRegistry = StorageLockRegistry()

    private var storageLock: NSLock {
        Self.lockRegistry.lock(forPath: storageURL.path)
    }

    public init(storageURL: URL, limit: Int) {
        precondition(limit >= 0, "FileHistoryStore limit must be non-negative")
        self.storageURL = storageURL
        self.limit = limit
    }

    public func save(item: ClipboardItem) throws {
        try storageLock.withLock {
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
        try storageLock.withLock {
            try recentItemsUnlocked()
        }
    }

    private func recentItemsUnlocked() throws -> [ClipboardItem] {
        guard FileManager.default.fileExists(atPath: storageURL.path) else { return [] }
        return try decoder.decode([ClipboardItem].self, from: Data(contentsOf: storageURL))
            .sorted(by: { $0.capturedAt > $1.capturedAt })
    }
}

private final class StorageLockRegistry: @unchecked Sendable {
    private let registryLock = NSLock()
    private var locks: [String: NSLock] = [:]

    func lock(forPath path: String) -> NSLock {
        registryLock.withLock {
            if let existing = locks[path] {
                return existing
            }

            let lock = NSLock()
            locks[path] = lock
            return lock
        }
    }
}

private extension NSLock {
    func withLock<T>(_ body: () -> T) -> T {
        lock()
        defer { unlock() }
        return body()
    }

    func withLock<T>(_ body: () throws -> T) throws -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
