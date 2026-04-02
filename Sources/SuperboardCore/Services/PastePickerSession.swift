import Combine
import Foundation

@MainActor
public final class PastePickerSession: ObservableObject {
    @Published public private(set) var visibleItems: [ClipboardItem] = []
    @Published public private(set) var selectedIndex: Int = -1

    public init() {}

    public func open(with items: [ClipboardItem]) {
        visibleItems = items
        selectedIndex = items.isEmpty ? -1 : 0
    }

    public func moveSelection(by offset: Int) {
        guard !visibleItems.isEmpty else { return }
        selectedIndex = max(0, min(visibleItems.count - 1, selectedIndex + offset))
    }

    public func chooseSelected() -> ClipboardItem? {
        guard visibleItems.indices.contains(selectedIndex) else { return nil }
        return visibleItems[selectedIndex]
    }
}
