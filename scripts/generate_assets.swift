import AppKit
import CoreGraphics

// Helper to save NSImage to PNG
func savePNG(image: NSImage, path: String) {
    guard let tiffData = image.tiffRepresentation,
          let bitmapRep = NSBitmapImageRep(data: tiffData),
          let pngData = bitmapRep.representation(using: .png, properties: [:]) else {
        print("Failed to convert image to PNG: \(path)")
        return
    }
    try? pngData.write(to: URL(fileURLWithPath: path))
    print("Saved asset: \(path)")
}

// 1. Generate Cursor Demo
func generateCursorDemo() -> NSImage {
    let width: CGFloat = 720
    let height: CGFloat = 320
    let size = NSSize(width: width, height: height)
    
    let image = NSImage(size: size)
    image.lockFocus()
    
    guard let ctx = NSGraphicsContext.current?.cgContext else { return image }
    
    // Background gradient (subtle dark macOS desktop background)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bgColors = [
        NSColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1.0).cgColor,
        NSColor(red: 0.08, green: 0.09, blue: 0.12, alpha: 1.0).cgColor
    ] as CFArray
    let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: height), end: CGPoint(x: 0, y: 0), options: [])
    
    // Card Window (Safari / Code Editor Text Input Mockup)
    let cardRect = CGRect(x: 60, y: 50, width: 600, height: 220)
    let cardPath = CGPath(roundedRect: cardRect, cornerWidth: 12, cornerHeight: 12, transform: nil)
    
    // Card shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -8), blur: 24, color: NSColor.black.withAlphaComponent(0.5).cgColor)
    ctx.setFillColor(NSColor(red: 0.18, green: 0.20, blue: 0.25, alpha: 1.0).cgColor)
    ctx.addPath(cardPath)
    ctx.fillPath()
    ctx.restoreGState()
    
    // Card border
    ctx.addPath(cardPath)
    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.12).cgColor)
    ctx.setLineWidth(1)
    ctx.strokePath()
    
    // Traffic light dots
    let dotColors: [NSColor] = [
        NSColor(red: 1.0, green: 0.36, blue: 0.34, alpha: 1.0),
        NSColor(red: 1.0, green: 0.75, blue: 0.18, alpha: 1.0),
        NSColor(red: 0.16, green: 0.80, blue: 0.25, alpha: 1.0)
    ]
    for (i, col) in dotColors.enumerated() {
        let dotRect = CGRect(x: cardRect.minX + 16 + CGFloat(i * 18), y: cardRect.maxY - 24, width: 10, height: 10)
        ctx.setFillColor(col.cgColor)
        ctx.fillEllipse(in: dotRect)
    }
    
    // Window title text
    let title = "Search or enter address"
    let titleFont = NSFont.systemFont(ofSize: 11, weight: .medium)
    let titleAttrs: [NSAttributedString.Key: Any] = [
        .font: titleFont,
        .foregroundColor: NSColor.white.withAlphaComponent(0.4)
    ]
    (title as NSString).draw(at: CGPoint(x: cardRect.midX - 70, y: cardRect.maxY - 27), withAttributes: titleAttrs)
    
    // Inner Search Input Bar
    let inputRect = CGRect(x: cardRect.minX + 32, y: cardRect.minY + 60, width: cardRect.width - 64, height: 50)
    let inputPath = CGPath(roundedRect: inputRect, cornerWidth: 8, cornerHeight: 8, transform: nil)
    ctx.setFillColor(NSColor(red: 0.13, green: 0.14, blue: 0.18, alpha: 1.0).cgColor)
    ctx.addPath(inputPath)
    ctx.fillPath()
    ctx.setStrokeColor(NSColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.8).cgColor)
    ctx.setLineWidth(1.5)
    ctx.addPath(inputPath)
    ctx.strokePath()
    
    // Typed Text inside Input
    let typedText = "git commit -m \"Fix typing detection\""
    let textFont = NSFont.monospacedSystemFont(ofSize: 15, weight: .regular)
    let textAttrs: [NSAttributedString.Key: Any] = [
        .font: textFont,
        .foregroundColor: NSColor.white
    ]
    let textOrigin = CGPoint(x: inputRect.minX + 18, y: inputRect.minY + 16)
    (typedText as NSString).draw(at: textOrigin, withAttributes: textAttrs)
    
    let textSize = (typedText as NSString).size(withAttributes: textAttrs)
    let cursorX = textOrigin.x + textSize.width + 4
    let cursorY = textOrigin.y - 1
    
    // I-Beam cursor line
    ctx.setStrokeColor(NSColor.white.cgColor)
    ctx.setLineWidth(1.8)
    ctx.strokeLineSegments(between: [
        CGPoint(x: cursorX, y: cursorY),
        CGPoint(x: cursorX, y: cursorY + 20)
    ])
    // I-beam top & bottom serifs
    ctx.strokeLineSegments(between: [
        CGPoint(x: cursorX - 3, y: cursorY + 20),
        CGPoint(x: cursorX + 3, y: cursorY + 20)
    ])
    ctx.strokeLineSegments(between: [
        CGPoint(x: cursorX - 3, y: cursorY),
        CGPoint(x: cursorX + 3, y: cursorY)
    ])
    
    // Floating Flag Indicator Badge at offset (14, -18)
    let flagOrigin = CGPoint(x: cursorX + 14, y: cursorY - 6)
    let flagSize = CGSize(width: 22, height: 16)
    let flagRect = CGRect(origin: flagOrigin, size: flagSize)
    
    // Flag shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -2), blur: 6, color: NSColor.black.withAlphaComponent(0.6).cgColor)
    
    // US Flag Drawing
    let flagPath = CGPath(roundedRect: flagRect, cornerWidth: 2.5, cornerHeight: 2.5, transform: nil)
    ctx.addPath(flagPath)
    ctx.clip()
    
    // Flag stripes
    let stripeHeight = flagRect.height / 7.0
    for s in 0..<7 {
        let sRect = CGRect(x: flagRect.minX, y: flagRect.minY + CGFloat(s) * stripeHeight, width: flagRect.width, height: stripeHeight)
        let sCol = (s % 2 == 0) ? NSColor(red: 0.85, green: 0.15, blue: 0.2, alpha: 1.0) : NSColor.white
        ctx.setFillColor(sCol.cgColor)
        ctx.fill(sRect)
    }
    // Flag canton
    let cantonRect = CGRect(x: flagRect.minX, y: flagRect.minY + 3 * stripeHeight, width: flagRect.width * 0.45, height: 4 * stripeHeight)
    ctx.setFillColor(NSColor(red: 0.1, green: 0.2, blue: 0.55, alpha: 1.0).cgColor)
    ctx.fill(cantonRect)
    ctx.restoreGState()
    
    // Border around flag
    ctx.addPath(flagPath)
    ctx.setStrokeColor(NSColor.black.withAlphaComponent(0.4).cgColor)
    ctx.setLineWidth(0.8)
    ctx.strokePath()
    
    // Callout badge: "FlagType Indicator"
    let callout = "Flag follows text cursor"
    let calloutFont = NSFont.systemFont(ofSize: 11, weight: .semibold)
    let calloutAttrs: [NSAttributedString.Key: Any] = [
        .font: calloutFont,
        .foregroundColor: NSColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0)
    ]
    (callout as NSString).draw(at: CGPoint(x: flagRect.maxX + 12, y: flagRect.minY + 1), withAttributes: calloutAttrs)
    
    image.unlockFocus()
    return image
}

// 2. Generate Menu Bar Demo
func generateMenuBarDemo() -> NSImage {
    let width: CGFloat = 720
    let height: CGFloat = 360
    let size = NSSize(width: width, height: height)
    
    let image = NSImage(size: size)
    image.lockFocus()
    
    guard let ctx = NSGraphicsContext.current?.cgContext else { return image }
    
    // Background gradient (macOS Ventura/Sonoma desktop style)
    let colorSpace = CGColorSpaceCreateDeviceRGB()
    let bgColors = [
        NSColor(red: 0.14, green: 0.16, blue: 0.22, alpha: 1.0).cgColor,
        NSColor(red: 0.09, green: 0.10, blue: 0.14, alpha: 1.0).cgColor
    ] as CFArray
    let bgGradient = CGGradient(colorsSpace: colorSpace, colors: bgColors, locations: [0.0, 1.0])!
    ctx.drawLinearGradient(bgGradient, start: CGPoint(x: 0, y: height), end: CGPoint(x: 0, y: 0), options: [])
    
    // Top Menu Bar strip
    let barRect = CGRect(x: 0, y: height - 36, width: width, height: 36)
    ctx.setFillColor(NSColor(red: 0.15, green: 0.16, blue: 0.20, alpha: 0.85).cgColor)
    ctx.fill(barRect)
    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.1).cgColor)
    ctx.setLineWidth(1)
    ctx.strokeLineSegments(between: [CGPoint(x: 0, y: barRect.minY), CGPoint(x: width, y: barRect.minY)])
    
    // Apple icon & Left Menu titles
    let barFont = NSFont.systemFont(ofSize: 13, weight: .medium)
    let barAttrs: [NSAttributedString.Key: Any] = [.font: barFont, .foregroundColor: NSColor.white.withAlphaComponent(0.85)]
    ("" as NSString).draw(at: CGPoint(x: 20, y: height - 26), withAttributes: barAttrs)
    ("File" as NSString).draw(at: CGPoint(x: 48, y: height - 26), withAttributes: barAttrs)
    ("Edit" as NSString).draw(at: CGPoint(x: 85, y: height - 26), withAttributes: barAttrs)
    ("View" as NSString).draw(at: CGPoint(x: 122, y: height - 26), withAttributes: barAttrs)
    
    // Status items on right side
    let statusX: CGFloat = width - 260
    
    // Draw FlagType Status Item Button (Ukrainian flag in menu bar)
    let flagRect = CGRect(x: statusX + 30, y: height - 27, width: 22, height: 16)
    let flagPath = CGPath(roundedRect: flagRect, cornerWidth: 2.0, cornerHeight: 2.0, transform: nil)
    ctx.saveGState()
    ctx.addPath(flagPath)
    ctx.clip()
    // Blue top
    ctx.setFillColor(NSColor(red: 0.0, green: 0.35, blue: 0.75, alpha: 1.0).cgColor)
    ctx.fill(CGRect(x: flagRect.minX, y: flagRect.minY + 8, width: 22, height: 8))
    // Yellow bottom
    ctx.setFillColor(NSColor(red: 1.0, green: 0.85, blue: 0.0, alpha: 1.0).cgColor)
    ctx.fill(CGRect(x: flagRect.minX, y: flagRect.minY, width: 22, height: 8))
    ctx.restoreGState()
    
    // Active status item highlight pill
    let pillRect = CGRect(x: statusX + 22, y: height - 32, width: 38, height: 26)
    let pillPath = CGPath(roundedRect: pillRect, cornerWidth: 5, cornerHeight: 5, transform: nil)
    ctx.setFillColor(NSColor.white.withAlphaComponent(0.15).cgColor)
    ctx.addPath(pillPath)
    ctx.fillPath()
    
    // Other system menu bar icons (WiFi, Battery, Control Center)
    ("􀙇" as NSString).draw(at: CGPoint(x: statusX + 80, y: height - 26), withAttributes: barAttrs)
    ("􀛨" as NSString).draw(at: CGPoint(x: statusX + 115, y: height - 26), withAttributes: barAttrs)
    ("10:42 PM" as NSString).draw(at: CGPoint(x: statusX + 155, y: height - 26), withAttributes: barAttrs)
    
    // Dropdown Menu Popover
    let menuRect = CGRect(x: statusX - 50, y: height - 280, width: 220, height: 242)
    let menuPath = CGPath(roundedRect: menuRect, cornerWidth: 8, cornerHeight: 8, transform: nil)
    
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12), blur: 30, color: NSColor.black.withAlphaComponent(0.55).cgColor)
    ctx.setFillColor(NSColor(red: 0.16, green: 0.17, blue: 0.22, alpha: 0.95).cgColor)
    ctx.addPath(menuPath)
    ctx.fillPath()
    ctx.restoreGState()
    
    ctx.addPath(menuPath)
    ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.12).cgColor)
    ctx.setLineWidth(1)
    ctx.strokePath()
    
    // Menu Items
    let items = [
        ("Ukrainian", true, true),
        ("U.S.", false, true),
        ("Polish", false, true),
        ("---", false, false),
        ("Show Flag at Cursor", true, false),
        ("Hide While Typing", true, false),
        ("Launch at Login", true, false),
        ("---", false, false),
        ("Quit FlagType", false, false)
    ]
    
    var currentY = menuRect.maxY - 26
    let itemFont = NSFont.systemFont(ofSize: 12, weight: .regular)
    let checkFont = NSFont.systemFont(ofSize: 12, weight: .bold)
    
    for item in items {
        if item.0 == "---" {
            ctx.setStrokeColor(NSColor.white.withAlphaComponent(0.08).cgColor)
            ctx.strokeLineSegments(between: [
                CGPoint(x: menuRect.minX + 10, y: currentY + 6),
                CGPoint(x: menuRect.maxX - 10, y: currentY + 6)
            ])
            currentY -= 12
            continue
        }
        
        let isSelected = item.0 == "Ukrainian"
        if isSelected {
            let rowRect = CGRect(x: menuRect.minX + 6, y: currentY - 5, width: menuRect.width - 12, height: 22)
            let rowPath = CGPath(roundedRect: rowRect, cornerWidth: 4, cornerHeight: 4, transform: nil)
            ctx.setFillColor(NSColor(red: 0.2, green: 0.45, blue: 0.9, alpha: 1.0).cgColor)
            ctx.addPath(rowPath)
            ctx.fillPath()
        }
        
        if item.1 {
            let checkAttrs: [NSAttributedString.Key: Any] = [
                .font: checkFont,
                .foregroundColor: NSColor.white
            ]
            ("✓" as NSString).draw(at: CGPoint(x: menuRect.minX + 12, y: currentY), withAttributes: checkAttrs)
        }
        
        let itemAttrs: [NSAttributedString.Key: Any] = [
            .font: itemFont,
            .foregroundColor: isSelected ? NSColor.white : NSColor.white.withAlphaComponent(0.85)
        ]
        (item.0 as NSString).draw(at: CGPoint(x: menuRect.minX + 32, y: currentY), withAttributes: itemAttrs)
        currentY -= 24
    }
    
    image.unlockFocus()
    return image
}

let fileManager = FileManager.default
try? fileManager.createDirectory(atPath: "docs/images", withIntermediateDirectories: true)

let cursorImg = generateCursorDemo()
savePNG(image: cursorImg, path: "docs/images/cursor_demo.png")

let menuImg = generateMenuBarDemo()
savePNG(image: menuImg, path: "docs/images/menubar_demo.png")

print("All demo graphics successfully generated!")
