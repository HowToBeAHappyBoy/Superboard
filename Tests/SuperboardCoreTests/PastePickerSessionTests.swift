import XCTest
@testable import SuperboardCore

final class PastePickerSessionTests: XCTestCase {
    func testOpenSelectsFirstItemByDefault() {
        let session = PastePickerSession()
        let items = [ClipboardItem.fixture(id: "1"), ClipboardItem.fixture(id: "2")]

        session.open(with: items)

        XCTAssertEqual(session.selectedIndex, 0)
        XCTAssertEqual(session.visibleItems.map(\.id), ["1", "2"])
    }

    func testMoveSelectionAdvancesWithinBounds() {
        let session = PastePickerSession()
        session.open(with: [ClipboardItem.fixture(id: "1"), ClipboardItem.fixture(id: "2")])

        session.moveSelection(by: 1)

        XCTAssertEqual(session.selectedIndex, 1)
    }

    func testChooseSelectedReturnsCurrentItem() {
        let session = PastePickerSession()
        session.open(with: [ClipboardItem.fixture(id: "1"), ClipboardItem.fixture(id: "2")])
        session.moveSelection(by: 1)

        XCTAssertEqual(session.chooseSelected()?.id, "2")
    }
}
