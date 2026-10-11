import AppKit
import Carbon

final class FlagProvider {
    static let shared = FlagProvider()
    
    private let cache = NSCache<NSString, NSImage>()
    
    // Normalization mapping for common variants
    private let fallbacks: [String: String] = [
        "com.apple.keylayout.Ukrainian-PC": "com.apple.keylayout.Ukrainian",
        "com.apple.keylayout.PolishPro": "com.apple.keylayout.Polish",
        "com.apple.keylayout.RussianWin": "com.apple.keylayout.Russian",
        "com.apple.keylayout.Russian-Phonetic": "com.apple.keylayout.Russian",
        "com.apple.keylayout.USInternational-PC": "com.apple.keylayout.US",
        "com.apple.keylayout.British-PC": "com.apple.keylayout.British",
        "com.apple.keylayout.German-DIN-2137": "com.apple.keylayout.German",
        "com.apple.keylayout.French-PC": "com.apple.keylayout.French",
        "com.apple.keylayout.French-numerical": "com.apple.keylayout.French",
        "com.apple.keylayout.Spanish-ISO": "com.apple.keylayout.Spanish",
        "com.apple.keylayout.Brazilian-ABNT2": "com.apple.keylayout.Brazilian",
        "com.apple.keylayout.Brazilian-Pro": "com.apple.keylayout.Brazilian"
    ]
    
    func flagImage(for inputSource: InputSource, size: CGSize = CGSize(width: 24, height: 16)) -> NSImage {
        let cacheKey = "\(inputSource.id)_\(Int(size.width))x\(Int(size.height))" as NSString
        if let cached = cache.object(forKey: cacheKey) {
            return cached
        }
        
        let image = loadFlagImage(for: inputSource.id, iconURL: inputSource.iconURL, localizedName: inputSource.localizedName)
        let resized = resize(image: image, targetSize: size)
        cache.setObject(resized, forKey: cacheKey)
        return resized
    }
    
    private func loadFlagImage(for id: String, iconURL: URL?, localizedName: String) -> NSImage {
        // 1. Try exact ID from bundled resources
        if let image = loadImage(named: id) {
            return image
        }
        
        // 2. Try normalized fallback ID
        if let fallbackID = fallbacks[id], let image = loadImage(named: fallbackID) {
            return image
        }
        
        // 3. Try system provided icon URL
        if let iconURL = iconURL, let image = NSImage(contentsOf: iconURL) {
            return image
        }
        
        // 4. Generate a fallback badge with text
        return generateBadge(text: badgeText(from: id, name: localizedName))
    }
    
    private func loadImage(named name: String) -> NSImage? {
        let bundle = Bundle.main
        
        // Check in Flags subdirectory
        if let url = bundle.url(forResource: name, withExtension: "png", subdirectory: "Flags"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        
        // Check directly in bundle resources
        if let url = bundle.url(forResource: name, withExtension: "png"),
           let image = NSImage(contentsOf: url) {
            return image
        }
        
        // Check NSImage(named:)
        if let image = NSImage(named: NSImage.Name(name)) {
            return image
        }
        
        return nil
    }
    
    private func badgeText(from id: String, name: String) -> String {
        let lower = id.lowercased()
        if lower.contains("ukrain") { return "UA" }
        if lower.contains("polish") { return "PL" }
        if lower.contains("russian") { return "RU" }
        if lower.contains(".us") { return "US" }
        if lower.contains("british") { return "GB" }
        if lower.contains("german") { return "DE" }
        if lower.contains("french") { return "FR" }
        if lower.contains("spanish") { return "ES" }
        if lower.contains("italian") { return "IT" }
        
        // Use first 2 letters of name
        let prefix = String(name.prefix(2)).uppercased()
        return prefix.isEmpty ? "??" : prefix
    }
    
    private func generateBadge(text: String) -> NSImage {
        let size = CGSize(width: 32, height: 22)
        let image = NSImage(size: size)
        image.lockFocus()
        
        let rect = NSRect(origin: .zero, size: size)
        let path = NSBezierPath(roundedRect: rect, xRadius: 4, yRadius: 4)
        NSColor(white: 0.15, alpha: 0.9).setFill()
        path.fill()
        
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.boldSystemFont(ofSize: 11),
            .foregroundColor: NSColor.white,
            .paragraphStyle: paragraph
        ]
        
        let textRect = NSRect(x: 0, y: 3, width: size.width, height: 16)
        (text as NSString).draw(in: textRect, withAttributes: attrs)
        
        image.unlockFocus()
        return image
    }
    
    private func contentBoundingBox(for image: NSImage) -> NSRect {
        guard let tiff = image.tiffRepresentation,
              let rep = NSBitmapImageRep(data: tiff) else {
            return NSRect(origin: .zero, size: image.size)
        }
        
        let width = rep.pixelsWide
        let height = rep.pixelsHigh
        guard width > 0 && height > 0 else {
            return NSRect(origin: .zero, size: image.size)
        }
        
        var minX = width, maxX = 0, minY = height, maxY = 0
        var foundAny = false
        
        for y in 0..<height {
            for x in 0..<width {
                if let color = rep.colorAt(x: x, y: y), color.alphaComponent > 0.05 {
                    foundAny = true
                    if x < minX { minX = x }
                    if x > maxX { maxX = x }
                    if y < minY { minY = y }
                    if y > maxY { maxY = y }
                }
            }
        }
        
        guard foundAny && maxX >= minX && maxY >= minY else {
            return NSRect(origin: .zero, size: image.size)
        }
        
        let scaleX = image.size.width / CGFloat(width)
        let scaleY = image.size.height / CGFloat(height)
        
        return NSRect(
            x: CGFloat(minX) * scaleX,
            y: CGFloat(height - 1 - maxY) * scaleY,
            width: CGFloat(maxX - minX + 1) * scaleX,
            height: CGFloat(maxY - minY + 1) * scaleY
        )
    }
    
    private func resize(image: NSImage, targetSize: CGSize) -> NSImage {
        let contentRect = contentBoundingBox(for: image)
        
        let newImage = NSImage(size: targetSize)
        newImage.lockFocus()
        
        let rect = NSRect(origin: .zero, size: targetSize)
        NSGraphicsContext.current?.imageInterpolation = .high
        image.draw(in: rect, from: contentRect, operation: .copy, fraction: 1.0)
        
        newImage.unlockFocus()
        return newImage
    }
}

