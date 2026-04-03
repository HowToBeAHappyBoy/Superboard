import CoreGraphics
import Foundation
import ImageIO
import UniformTypeIdentifiers

func usageAndExit() -> Never {
fputs("Usage: generate-dmg-background.swift <output-path(.png|.tiff)> [width] [height]\n", stderr)
    exit(2)
}

let args = CommandLine.arguments
guard args.count >= 2 else { usageAndExit() }
let outputPath = args[1]
let width = args.count >= 3 ? (Int(args[2]) ?? 560) : 560
let height = args.count >= 4 ? (Int(args[3]) ?? 360) : 360

guard width > 0, height > 0 else {
    fputs("Invalid size\n", stderr)
    exit(2)
}

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

// Use a top-left origin coordinate system.
context.translateBy(x: 0, y: canvas.height)
context.scaleBy(x: 1, y: -1)

// Background gradient (light, Finder-friendly).
let start = CGColor(red: 0.965, green: 0.965, blue: 0.970, alpha: 1.0)
let end = CGColor(red: 0.915, green: 0.920, blue: 0.935, alpha: 1.0)
let gradient = CGGradient(colorsSpace: colorSpace, colors: [start, end] as CFArray, locations: [0, 1])!
context.drawLinearGradient(
    gradient,
    start: CGPoint(x: 0, y: 0),
    end: CGPoint(x: canvas.maxX, y: canvas.maxY),
    options: []
)

// Subtle backdrop plate to hint the drop interaction.
let plateRect = CGRect(
    x: canvas.width * 0.08,
    y: canvas.height * 0.36,
    width: canvas.width * 0.84,
    height: canvas.height * 0.42
)
let platePath = CGMutablePath()
platePath.addRoundedRect(in: plateRect, cornerWidth: 18, cornerHeight: 18)
context.addPath(platePath)
context.setFillColor(CGColor(gray: 1.0, alpha: 0.55))
context.fillPath()

// Arrow (drag to Applications).
context.saveGState()
let arrowCenter = CGPoint(x: canvas.width * 0.510, y: canvas.height * 0.583) // between icons (shifted left)
let arrowWidth = canvas.width * 0.16
let arrowHeight = canvas.height * 0.11

let shaftLeft = CGPoint(x: arrowCenter.x - arrowWidth * 0.55, y: arrowCenter.y)
let shaftRight = CGPoint(x: arrowCenter.x + arrowWidth * 0.15, y: arrowCenter.y)
let headTop = CGPoint(x: arrowCenter.x + arrowWidth * 0.15, y: arrowCenter.y - arrowHeight * 0.55)
let headTip = CGPoint(x: arrowCenter.x + arrowWidth * 0.55, y: arrowCenter.y)
let headBottom = CGPoint(x: arrowCenter.x + arrowWidth * 0.15, y: arrowCenter.y + arrowHeight * 0.55)

let path = CGMutablePath()
path.move(to: shaftLeft)
path.addLine(to: shaftRight)
path.move(to: headTop)
path.addLine(to: headTip)
path.addLine(to: headBottom)

context.addPath(path)
context.setStrokeColor(CGColor(gray: 0.35, alpha: 0.65))
context.setLineWidth(max(2, canvas.width * 0.0045))
context.setLineCap(.round)
context.setLineJoin(.round)
context.setLineDash(phase: 0, lengths: [7, 7])
context.strokePath()
context.restoreGState()

// Export.
guard let image = context.makeImage() else {
    fputs("Failed to make CGImage\n", stderr)
    exit(1)
}

let outputURL = URL(fileURLWithPath: outputPath)
let type: UTType
if outputURL.pathExtension.lowercased() == "tiff" || outputURL.pathExtension.lowercased() == "tif" {
    type = .tiff
} else {
    type = .png
}

let url = outputURL as CFURL
guard let destination = CGImageDestinationCreateWithURL(url, type.identifier as CFString, 1, nil) else {
    fputs("Failed to create image destination\n", stderr)
    exit(1)
}

CGImageDestinationAddImage(destination, image, nil)
guard CGImageDestinationFinalize(destination) else {
    fputs("Failed to write image\n", stderr)
    exit(1)
}
