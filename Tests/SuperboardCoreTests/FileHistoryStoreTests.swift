import XCTest
@testable import SuperboardCore

final class FileHistoryStoreTests: XCTestCase {
    func testMostRecentItemsAreReturnedFirst() throws {
        let store = try FileHistoryStore.makeTestStore(limit: 10)
        try store.save(item: .fixture(id: "1", capturedAt: Date(timeIntervalSince1970: 10)))
        try store.save(item: .fixture(id: "2", capturedAt: Date(timeIntervalSince1970: 20)))

        XCTAssertEqual(try store.recentItems().map(\.id), ["2", "1"])
    }

    func testDuplicateFingerprintReplacesOlderItem() throws {
        let store = try FileHistoryStore.makeTestStore(limit: 10)
        try store.save(item: .fixture(id: "1", fingerprint: "same"))
        try store.save(item: .fixture(id: "2", fingerprint: "same"))

        XCTAssertEqual(try store.recentItems().map(\.id), ["2"])
    }

    func testRetentionDropsOldestItemsPastLimit() throws {
        let store = try FileHistoryStore.makeTestStore(limit: 2)
        try store.save(item: .fixture(id: "1", capturedAt: .distantPast))
        try store.save(item: .fixture(id: "2", capturedAt: Date(timeIntervalSince1970: 10)))
        try store.save(item: .fixture(id: "3", capturedAt: Date(timeIntervalSince1970: 20)))

        XCTAssertEqual(try store.recentItems().map(\.id), ["3", "2"])
    }

    func testSavingOlderItemLaterDoesNotEvictNewerItems() throws {
        let store = try FileHistoryStore.makeTestStore(limit: 2)
        try store.save(item: .fixture(id: "newest", capturedAt: Date(timeIntervalSince1970: 20)))
        try store.save(item: .fixture(id: "middle", capturedAt: Date(timeIntervalSince1970: 10)))
        try store.save(item: .fixture(id: "oldest", capturedAt: Date(timeIntervalSince1970: 5)))

        XCTAssertEqual(try store.recentItems().map(\.id), ["newest", "middle"])
    }

    func testItemsRoundTripAcrossStoreInstances() throws {
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let writer = FileHistoryStore(storageURL: url, limit: 10)
        try writer.save(item: .fixture(id: "1", capturedAt: Date(timeIntervalSince1970: 10)))
        try writer.save(item: .fixture(id: "2", capturedAt: Date(timeIntervalSince1970: 20)))

        let reader = FileHistoryStore(storageURL: url, limit: 10)
        XCTAssertEqual(try reader.recentItems().map(\.id), ["2", "1"])
    }
}

extension ClipboardItem {
    static func fixture(
        id: String,
        capturedAt: Date = Date(),
        fingerprint: String? = nil
    ) -> ClipboardItem {
        ClipboardItem(
            id: id,
            workspaceId: Workspace.local.id,
            capturedAt: capturedAt,
            sourceAppID: "com.apple.TextEdit",
            sourceAppName: "TextEdit",
            content: .text("item-\(id)"),
            fingerprint: fingerprint ?? "fp-\(id)"
        )
    }
}

extension FileHistoryStore {
    static func makeTestStore(limit: Int, storageURL: URL? = nil) throws -> FileHistoryStore {
        let url = storageURL ?? FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        return FileHistoryStore(storageURL: url, limit: limit)
    }
}
