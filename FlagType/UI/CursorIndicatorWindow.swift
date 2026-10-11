import AppKit

final class CursorIndicatorView: NSView {
    private let imageView = NSImageView()
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        wantsLayer = true
        layer?.cornerRadius = 3
        layer?.masksToBounds = true
        layer?.borderWidth = 0.5
        layer?.borderColor = NSColor(white: 0.0, alpha: 0.35).cgColor
        
        imageView.imageScaling = .scaleAxesIndependently
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    func setImage(_ image: NSImage) {
        imageView.image = image
    }
}

final class CursorIndicatorWindow: NSWindow {
    private let indicatorView = CursorIndicatorView()
    static let windowSize = CGSize(width: 22, height: 15)
    
    init() {
        let contentRect = NSRect(origin: .zero, size: CursorIndicatorWindow.windowSize)
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        ignoresMouseEvents = true
        level = .popUpMenu
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        
        contentView = indicatorView
    }
    
    func updateImage(_ image: NSImage) {
        indicatorView.setImage(image)
    }
    
    func setPosition(near point: CGPoint) {
        // Place flag slightly to the right and below the cursor tip
        let offset = CGPoint(x: 14, y: -18)
        let origin = CGPoint(
            x: point.x + offset.x,
            y: point.y + offset.y
        )
        setFrameOrigin(origin)
    }
}
