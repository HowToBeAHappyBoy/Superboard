import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

func usageAndExit() -> Never {
    fputs("Usage: generate-app-icon.swift <output-png-path> [size]\n", stderr)
    exit(2)
}

let args = CommandLine.arguments
guard args.count >= 2 else { usageAndExit() }
let outputPath = args[1]
let size = args.count >= 3 ? (Int(args[2]) ?? 1024) : 1024

guard size > 0 else {
    fputs("Invalid size\n", stderr)
    exit(2)
}

let width = size
let height = size
let colorSpace = CGColorSpaceCreateDeviceRGB()
let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)

guard let context = CGContext(
    data: nil,
    width: width,
    height: height,
    bitsPerComponent: 8,
    bytesPerRow: 0,
    space: colorSpace,
    bitmapInfo: bitmapInfo.rawValue
) else {
    fputs("Failed to create CGContext\n", stderr)
    exit(1)
}

context.setShouldAntialias(true)
context.setAllowsAntialiasing(true)
context.interpolationQuality = .high

let canvas = CGRect(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height))

// Use a top-left origin coordinate system so our icon geometry matches typical design specs.
context.translateBy(x: 0, y: canvas.height)
context.scaleBy(x: 1, y: -1)

func addRoundedRect(_ rect: CGRect, radius: CGFloat) {
    let path = CGMutablePath()
    path.addRoundedRect(in: rect, cornerWidth: radius, cornerHeight: radius)
    context.addPath(path)
}

// Background (A1 dark solid).
let backgroundRadius = CGFloat(size) * 0.222
addRoundedRect(canvas, radius: backgroundRadius)
context.setFillColor(CGColor(red: 0.043, green: 0.047, blue: 0.063, alpha: 1.0))
context.fillPath()

// Deck group (A + 3: minimal + slight tilt).
let deckWidth = CGFloat(size) * 0.689
let deckHeight = CGFloat(size) * 0.200
let deckRadius = deckHeight / 2
let deckOrigin = CGPoint(x: (canvas.width - deckWidth) / 2, y: canvas.height * 0.378)
let deckRect = CGRect(origin: deckOrigin, size: CGSize(width: deckWidth, height: deckHeight))

context.saveGState()
let angle: CGFloat = -10 * .pi / 180
context.translateBy(x: canvas.midX, y: canvas.midY)
context.rotate(by: angle)
context.translateBy(x: -canvas.midX, y: -canvas.midY)

addRoundedRect(deckRect, radius: deckRadius)
context.setFillColor(CGColor(gray: 1.0, alpha: 1.0))
context.fillPath()

// Wheels.
let wheelRadius = CGFloat(size) * 0.044
let wheelY = canvas.height * 0.656
let leftWheelX = canvas.width * 0.311
let rightWheelX = canvas.width * 0.689
context.setFillColor(CGColor(gray: 1.0, alpha: 0.85))
context.fillEllipse(in: CGRect(x: leftWheelX - wheelRadius, y: wheelY - wheelRadius, width: wheelRadius * 2, height: wheelRadius * 2))
context.fillEllipse(in: CGRect(x: rightWheelX - wheelRadius, y: wheelY - wheelRadius, width: wheelRadius * 2, height: wheelRadius * 2))

context.restoreGState()

guard let image = context.makeImage() else {
    fputs("Failed to make CGImage\n", stderr)
    exit(1)
}

let url = URL(fileURLWithPath: outputPath) as CFURL
guard let destination = CGImageDestinationCreateWithURL(url, UTType.png.identifier as CFString, 1, nil) else {
    fputs("Failed to create PNG destination\n", stderr)
    exit(1)
}

CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else {
    fputs("Failed to write PNG\n", stderr)
    exit(1)
}
