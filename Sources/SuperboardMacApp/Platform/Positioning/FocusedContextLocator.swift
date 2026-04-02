import AppKit

struct FocusedContextLocator {
    func pickerOrigin() -> CGPoint {
        if let frame = NSScreen.main?.visibleFrame {
            return CGPoint(x: frame.midX - 180, y: frame.midY + 80)
        }
        return CGPoint(x: 900, y: 620)
    }
}
