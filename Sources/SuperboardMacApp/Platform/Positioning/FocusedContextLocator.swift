import AppKit
import Foundation

struct FocusedContextLocator {
    func pickerOrigin(
        panelSize: CGSize,
        cursorLocation: CGPoint = NSEvent.mouseLocation,
        preferredApplicationPID: pid_t? = nil
    ) -> CGPoint {
        let fallback = CGPoint(x: 900, y: 620)

        let screen = NSScreen.screens.first(where: { NSMouseInRect(cursorLocation, $0.frame, false) })
        guard let frame = (screen ?? NSScreen.main)?.visibleFrame else {
            DebugLog.write("Locator: no screen; fallback=\(Int(fallback.x)),\(Int(fallback.y))")
            return fallback
        }

        let origin = centeredOrigin(in: frame, panelSize: panelSize)
        DebugLog.write(
            "Locator: centered cursor=\(Int(cursorLocation.x)),\(Int(cursorLocation.y)) " +
                "screen=\(Int(frame.minX)),\(Int(frame.minY)) \(Int(frame.width))x\(Int(frame.height)) " +
                "origin=\(Int(origin.x)),\(Int(origin.y)) size=\(Int(panelSize.width))x\(Int(panelSize.height))"
        )
        return origin
    }

    private func centeredOrigin(in frame: CGRect, panelSize: CGSize) -> CGPoint {
        CGPoint(
            x: frame.midX - (panelSize.width / 2),
            y: frame.midY - (panelSize.height / 2)
        )
    }
}
