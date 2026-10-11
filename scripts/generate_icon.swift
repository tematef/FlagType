import AppKit
import CoreGraphics

func createIconImage(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }
    
    let scale = size / 1024.0
    
    // Squircle background (macOS standard icon dimensions: 824x824 at 1024, centered)
    let squircleSize: CGFloat = 824.0 * scale
    let squircleOffset: CGFloat = (size - squircleSize) / 2.0
    let squircleRect = CGRect(x: squircleOffset, y: squircleOffset, width: squircleSize, height: squircleSize)
    let cornerRadius: CGFloat = 185.0 * scale
    
    let squirclePath = CGPath(roundedRect: squircleRect, cornerWidth: cornerRadius, cornerHeight: cornerRadius, transform: nil)
    
    // Save state for drop shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12.0 * scale), blur: 24.0 * scale, color: NSColor(white: 0, alpha: 0.35).cgColor)
    ctx.addPath(squirclePath)
    ctx.setFillColor(NSColor(red: 0.1, green: 0.12, blue: 0.22, alpha: 1.0).cgColor)
    ctx.fillPath()
    ctx.restoreGState()
    
    // Draw background gradient inside squircle
    ctx.saveGState()
    ctx.addPath(squirclePath)
    ctx.clip()
    
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bgColors = [
        NSColor(red: 0.14, green: 0.18, blue: 0.32, alpha: 1.0).cgColor, // Top indigo
        NSColor(red: 0.08, green: 0.09, blue: 0.18, alpha: 1.0).cgColor  // Bottom midnight
    ] as CFArray
    let bgLocations: [CGFloat] = [0.0, 1.0]
    if let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: bgLocations) {
        ctx.drawLinearGradient(bgGradient, start: CGPoint(x: size / 2, y: size - squircleOffset), end: CGPoint(x: size / 2, y: squircleOffset), options: [])
    }
    
    // Subtle top specular highlight
    let highlightRect = CGRect(x: squircleOffset, y: size - squircleOffset - (squircleSize * 0.45), width: squircleSize, height: squircleSize * 0.45)
    let highlightColors = [
        NSColor(white: 1.0, alpha: 0.08).cgColor,
        NSColor(white: 1.0, alpha: 0.0).cgColor
    ] as CFArray
    if let hlGradient = CGGradient(colorsSpace: colorSpace, colors: highlightColors, locations: [0.0, 1.0]) {
        ctx.saveGState()
        ctx.clip(to: highlightRect)
        ctx.drawLinearGradient(hlGradient, start: CGPoint(x: size / 2, y: size - squircleOffset), end: CGPoint(x: size / 2, y: size - squircleOffset - (squircleSize * 0.45)), options: [])
        ctx.restoreGState()
    }
    
    // Inner border
    ctx.addPath(squirclePath)
    ctx.setStrokeColor(NSColor(white: 1.0, alpha: 0.15).cgColor)
    ctx.setLineWidth(1.5 * scale)
    ctx.strokePath()
    
    // Center Motif: Sleek Stylized Cursor + Flag Ribbon
    let centerX = size / 2.0
    let centerY = size / 2.0
    
    // 1. Sleek Flag Badge (Floating rounded pill / mini flag)
    let flagWidth: CGFloat = 340.0 * scale
    let flagHeight: CGFloat = 220.0 * scale
    let flagX: CGFloat = centerX - 120.0 * scale
    let flagY: CGFloat = centerY - 60.0 * scale
    let flagRect = CGRect(x: flagX, y: flagY, width: flagWidth, height: flagHeight)
    let flagRadius: CGFloat = 40.0 * scale
    let flagPath = CGPath(roundedRect: flagRect, cornerWidth: flagRadius, cornerHeight: flagRadius, transform: nil)
    
    // Flag shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -8.0 * scale), blur: 16.0 * scale, color: NSColor(white: 0, alpha: 0.3).cgColor)
    ctx.addPath(flagPath)
    ctx.setFillColor(NSColor(white: 0.2, alpha: 0.5).cgColor)
    ctx.fillPath()
    ctx.restoreGState()
    
    // Draw flag halves (Top Cyan/Azure, Bottom Amber/Gold)
    ctx.saveGState()
    ctx.addPath(flagPath)
    ctx.clip()
    
    // Top half: Azure / Electric Blue gradient
    let topHalfRect = CGRect(x: flagX, y: flagY + flagHeight / 2.0, width: flagWidth, height: flagHeight / 2.0)
    let topColors = [
        NSColor(red: 0.20, green: 0.60, blue: 1.0, alpha: 1.0).cgColor,
        NSColor(red: 0.05, green: 0.45, blue: 0.95, alpha: 1.0).cgColor
    ] as CFArray
    if let topGrad = CGGradient(colorsSpace: colorSpace, colors: topColors, locations: [0.0, 1.0]) {
        ctx.drawLinearGradient(topGrad, start: CGPoint(x: flagX, y: topHalfRect.maxY), end: CGPoint(x: flagX, y: topHalfRect.minY), options: [])
    }
    
    // Bottom half: Vibrant Golden Yellow gradient
    let btmHalfRect = CGRect(x: flagX, y: flagY, width: flagWidth, height: flagHeight / 2.0)
    let btmColors = [
        NSColor(red: 1.0, green: 0.82, blue: 0.18, alpha: 1.0).cgColor,
        NSColor(red: 0.95, green: 0.70, blue: 0.08, alpha: 1.0).cgColor
    ] as CFArray
    if let btmGrad = CGGradient(colorsSpace: colorSpace, colors: btmColors, locations: [0.0, 1.0]) {
        ctx.drawLinearGradient(btmGrad, start: CGPoint(x: flagX, y: btmHalfRect.maxY), end: CGPoint(x: flagX, y: btmHalfRect.minY), options: [])
    }
    
    // Border around flag badge
    ctx.addPath(flagPath)
    ctx.setStrokeColor(NSColor(white: 1.0, alpha: 0.25).cgColor)
    ctx.setLineWidth(2.0 * scale)
    ctx.strokePath()
    ctx.restoreGState()
    
    // 2. Crisp Mac Cursor Arrow pointing at flag
    let cursorPath = CGMutablePath()
    let curTip = CGPoint(x: centerX + 90.0 * scale, y: centerY + 140.0 * scale)
    cursorPath.move(to: curTip)
    cursorPath.addLine(to: CGPoint(x: curTip.x, y: curTip.y - 280.0 * scale))
    cursorPath.addLine(to: CGPoint(x: curTip.x + 70.0 * scale, y: curTip.y - 210.0 * scale))
    cursorPath.addLine(to: CGPoint(x: curTip.x + 130.0 * scale, y: curTip.y - 330.0 * scale))
    cursorPath.addLine(to: CGPoint(x: curTip.x + 180.0 * scale, y: curTip.y - 305.0 * scale))
    cursorPath.addLine(to: CGPoint(x: curTip.x + 120.0 * scale, y: curTip.y - 185.0 * scale))
    cursorPath.addLine(to: CGPoint(x: curTip.x + 200.0 * scale, y: curTip.y - 185.0 * scale))
    cursorPath.closeSubpath()
    
    // Cursor Shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -10.0 * scale), blur: 20.0 * scale, color: NSColor(white: 0, alpha: 0.45).cgColor)
    ctx.addPath(cursorPath)
    ctx.setFillColor(NSColor.black.cgColor)
    ctx.fillPath()
    ctx.restoreGState()
    
    // Cursor Fill: Crisp bright white
    ctx.saveGState()
    ctx.addPath(cursorPath)
    ctx.setFillColor(NSColor.white.cgColor)
    ctx.fillPath()
    
    // Cursor border
    ctx.addPath(cursorPath)
    ctx.setStrokeColor(NSColor(white: 0.1, alpha: 0.8).cgColor)
    ctx.setLineWidth(3.0 * scale)
    ctx.strokePath()
    ctx.restoreGState()
    
    ctx.restoreGState() // restore squircle clip
    
    image.unlockFocus()
    return image
}

let iconSizes: [(String, CGFloat)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

let outputDir = "/tmp/FlagType.iconset"
try? FileManager.default.removeItem(atPath: outputDir)
try? FileManager.default.createDirectory(atPath: outputDir, withIntermediateDirectories: true)

for (filename, size) in iconSizes {
    let img = createIconImage(size: size)
    if let tiff = img.tiffRepresentation,
       let rep = NSBitmapImageRep(data: tiff),
       let png = rep.representation(using: .png, properties: [:]) {
        let path = "\(outputDir)/\(filename)"
        try? png.write(to: URL(fileURLWithPath: path))
    }
}

print("Iconset created at \(outputDir)")
