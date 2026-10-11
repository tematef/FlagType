import AppKit

final class CursorIndicatorManager {
    static let shared = CursorIndicatorManager()
    
    private let window = CursorIndicatorWindow()
    private var globalMouseMonitor: Any?
    private var localMouseMonitor: Any?
    private var keyMonitor: Any?
    private var checkTimer: Timer?
    
    private var isVisible = false
    private var isTyping = false
    private var typingResetTimer: Timer?
    
    private init() {
        setupInputSourceObserver()
    }
    
    func start() {
        updateImage()
        setupMonitors()
        setupTimer()
    }
    
    func stop() {
        removeMonitors()
        checkTimer?.invalidate()
        checkTimer = nil
        hide()
    }
    
    func updateImage() {
        guard let source = InputSourceManager.shared.currentInputSource else { return }
        let flag = FlagProvider.shared.flagImage(for: source, size: CursorIndicatorWindow.windowSize)
        window.updateImage(flag)
    }
    
    private func setupInputSourceObserver() {
        InputSourceManager.shared.onInputSourceChanged = { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateImage()
                if self?.isVisible == true {
                    self?.showAtCurrentCursor()
                }
            }
        }
    }
    
    private func setupMonitors() {
        // Global mouse move monitor
        globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged]
        ) { [weak self] _ in
            self?.handleMouseMoved()
        }
        
        // Local mouse move monitor
        localMouseMonitor = NSEvent.addLocalMonitorForEvents(
            matching: [.mouseMoved, .leftMouseDragged, .rightMouseDragged]
        ) { [weak self] event in
            self?.handleMouseMoved()
            return event
        }
        
        // Global key press monitor to hide while typing
        keyMonitor = NSEvent.addGlobalMonitorForEvents(
            matching: [.keyDown]
        ) { [weak self] _ in
            self?.handleKeyDown()
        }
    }
    
    private func removeMonitors() {
        if let monitor = globalMouseMonitor {
            NSEvent.removeMonitor(monitor)
            globalMouseMonitor = nil
        }
        if let monitor = localMouseMonitor {
            NSEvent.removeMonitor(monitor)
            localMouseMonitor = nil
        }
        if let monitor = keyMonitor {
            NSEvent.removeMonitor(monitor)
            keyMonitor = nil
        }
    }
    
    private func setupTimer() {
        // Check cursor state every 0.05s for responsiveness
        checkTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { [weak self] _ in
            self?.checkCursorState()
        }
    }
    
    private func handleMouseMoved() {
        isTyping = false
        typingResetTimer?.invalidate()
        checkCursorState()
    }
    
    private func handleKeyDown() {
        guard Settings.shared.hideWhileTyping else { return }
        isTyping = true
        hide()
        
        typingResetTimer?.invalidate()
        // Reset typing state after 0.8s of inactivity
        typingResetTimer = Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false) { [weak self] _ in
            self?.isTyping = false
            self?.checkCursorState()
        }
    }
    
    private func isIBeamCursor() -> Bool {
        guard let cur = NSCursor.currentSystem else { return false }
        let hs = cur.hotSpot
        let x = round(hs.x)
        let y = round(hs.y)
        
        // Standard horizontal I-beam: centered vertically on line of text
        // HotSpot on macOS is (4, 9) on standard/retina displays, or (4, 8)-(4, 12)
        if x == 4.0 && (y >= 8.0 && y <= 12.0) {
            return true
        }
        // Vertical layout I-beam: (7, 4) or (6-8, 4)
        if (x >= 6.0 && x <= 8.0) && y == 4.0 {
            return true
        }
        return false
    }
    
    private func checkCursorState() {
        guard Settings.shared.showCursorIndicator else {
            if isVisible { hide() }
            return
        }
        
        if isTyping && Settings.shared.hideWhileTyping {
            if isVisible { hide() }
            return
        }
        
        if isIBeamCursor() {
            showAtCurrentCursor()
        } else {
            if isVisible {
                hide()
            }
        }
    }
    
    private func showAtCurrentCursor() {
        let mouseLocation = NSEvent.mouseLocation
        window.setPosition(near: mouseLocation)
        
        if !isVisible {
            window.orderFrontRegardless()
            isVisible = true
        }
    }
    
    private func hide() {
        if isVisible {
            window.orderOut(nil)
            isVisible = false
        }
    }
}
