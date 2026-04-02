import XCTest
@testable import SuperboardCore

final class ClipboardItemTests: XCTestCase {
    func testTextItemPreviewUsesFirstLine() {
        let item = ClipboardItem(
            id: "1",
            workspaceId: Workspace.local.id,
            capturedAt: .distantPast,
            sourceAppID: "com.apple.TextEdit",
            sourceAppName: "TextEdit",
            content: .text("first line\nsecond line")
        )

        XCTAssertEqual(item.previewText, "first line")
        XCTAssertFalse(item.isSensitive)
    }

    func testImageItemPreservesDimensionsMetadata() {
        let item = ClipboardItem(
            id: "2",
            workspaceId: Workspace.local.id,
            capturedAt: .distantPast,
            sourceAppID: "com.apple.Preview",
            sourceAppName: "Preview",
            content: .image(data: Data([0x01, 0x02]), width: 640, height: 480)
        )

        XCTAssertEqual(item.previewText, "Image 640×480")
    }

    func testFileItemPreviewIncludesFileCount() {
        let item = ClipboardItem(
            id: "3",
            workspaceId: Workspace.local.id,
            capturedAt: .distantPast,
            sourceAppID: "com.apple.finder",
            sourceAppName: "Finder",
            content: .files([URL(fileURLWithPath: "/tmp/a.png"), URL(fileURLWithPath: "/tmp/b.png")])
        )

        XCTAssertEqual(item.previewText, "2 files")
    }
}
