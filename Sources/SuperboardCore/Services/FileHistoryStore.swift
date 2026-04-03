import Foundation
import Dispatch

public final class FileHistoryStore: HistoryStore, @unchecked Sendable {
    private let storageURL: URL
    private var limit: Int
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private static let lockRegistry = StorageLockRegistry()
    private let writeQueue = DispatchQueue(label: "com.superboard.fileHistoryStore.writeQueue")
    private var cachedItems: [ClipboardItem]

    private var storageLock: NSLock {
        Self.lockRegistry.lock(forPath: storageURL.path)
    }

    public init(storageURL: URL, limit: Int) {
        precondition(limit >= 0, "FileHistoryStore limit must be non-negative")
        self.storageURL = storageURL
        self.limit = limit
        self.cachedItems = []

        let loaded = (try? Self.loadItems(from: storageURL, decoder: decoder)) ?? []
        self.cachedItems = loaded.sorted(by: { $0.capturedAt > $1.capturedAt })
        if self.cachedItems.count > limit {
            self.cachedItems = Array(self.cachedItems.prefix(limit))
            // Best-effort trim on init so the on-disk file doesn't grow past the configured limit.
            try? writeQueue.sync {
                let data = try encoder.encode(self.cachedItems)
                try data.write(to: storageURL, options: .atomic)
            }
        }
    }

    public func updateLimit(_ newLimit: Int) throws {
        precondition(newLimit >= 0, "FileHistoryStore limit must be non-negative")
        let dataToWrite: Data? = try storageLock.withLock {
            limit = newLimit
            if cachedItems.count <= newLimit {
                return nil
            }

            cachedItems = Array(cachedItems.prefix(newLimit))
            return try encoder.encode(cachedItems)
        }

        if let dataToWrite {
            try writeData(dataToWrite)
        }
    }

    public func save(item: ClipboardItem) throws {
        let dataToWrite: Data = try storageLock.withLock {
            var items = cachedItems
            items.removeAll { $0.fingerprint == item.fingerprint }
            items.insert(item, at: 0)
            items.sort(by: { $0.capturedAt > $1.capturedAt })
            if items.count > limit {
                items = Array(items.prefix(limit))
            }
            cachedItems = items
            return try encoder.encode(items)
        }
        try writeData(dataToWrite)
    }

    public func recentItems() throws -> [ClipboardItem] {
        storageLock.withLock { cachedItems }
    }

    private func writeData(_ data: Data) throws {
        try writeQueue.sync {
            try data.write(to: storageURL, options: .atomic)
        }
    }

    private static func loadItems(from url: URL, decoder: JSONDecoder) throws -> [ClipboardItem] {
        guard FileManager.default.fileExists(atPath: url.path) else { return [] }
        return try decoder.decode([ClipboardItem].self, from: Data(contentsOf: url))
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
