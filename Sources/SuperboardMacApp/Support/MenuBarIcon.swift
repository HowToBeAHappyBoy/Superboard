import AppKit

enum MenuBarIcon {
    static func skateboardTemplateImage(pointSize: CGFloat = 18) -> NSImage {
        let size = NSSize(width: pointSize, height: pointSize)
        let image = NSImage(size: size)

        image.lockFocusFlipped(false)
        defer { image.unlockFocus() }

        let context = NSGraphicsContext.current?.cgContext
        context?.saveGState()
        defer { context?.restoreGState() }

        context?.setShouldAntialias(true)
        context?.setAllowsAntialiasing(true)
        context?.interpolationQuality = .high

        // Draw in solid black; system will tint template images automatically.
        NSColor.black.setFill()

        let w = size.width
        let h = size.height

        let deckWidth = w * 0.84
        let deckHeight = h * 0.22
        let deckRadius = deckHeight / 2
        let deckRect = CGRect(
            x: (w - deckWidth) / 2,
            y: (h - deckHeight) / 2 + (h * 0.06),
            width: deckWidth,
            height: deckHeight
        )

        let wheelRadius = h * 0.075
        let wheelY = deckRect.minY - (wheelRadius * 0.9)
        let leftWheelX = deckRect.minX + (deckWidth * 0.28)
        let rightWheelX = deckRect.minX + (deckWidth * 0.72)

        // Slight tilt to match the app icon direction (A1 + 3).
        context?.translateBy(x: w / 2, y: h / 2)
        context?.rotate(by: (-10 * .pi) / 180)
        context?.translateBy(x: -w / 2, y: -h / 2)

        NSBezierPath(roundedRect: deckRect, xRadius: deckRadius, yRadius: deckRadius).fill()
        NSBezierPath(ovalIn: CGRect(x: leftWheelX - wheelRadius, y: wheelY - wheelRadius, width: wheelRadius * 2, height: wheelRadius * 2)).fill()
        NSBezierPath(ovalIn: CGRect(x: rightWheelX - wheelRadius, y: wheelY - wheelRadius, width: wheelRadius * 2, height: wheelRadius * 2)).fill()

        image.isTemplate = true
        return image
    }
}
