import AppKit
import SuperboardCore

final class MacClipboardWatcher {
    private let pasteboard = NSPasteboard.general
    private let reader = MacPasteboardReader()
    private let historyStore: HistoryStore
    private var changeCount: Int
    private var timer: Timer?

    init(historyStore: HistoryStore) {
        self.historyStore = historyStore
        self.changeCount = pasteboard.changeCount
    }

    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true) { [weak self] _ in
            self?.poll()
        }
    }

    func stop() {
        timer?.invalidate()
        timer = nil
    }

    private func poll() {
        guard pasteboard.changeCount != changeCount else { return }
        changeCount = pasteboard.changeCount
        guard let item = reader.readCurrentItem() else { return }
        try? historyStore.save(item: item)
    }
}
