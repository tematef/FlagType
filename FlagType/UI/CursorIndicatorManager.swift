import AppKit

final class CursorIndicatorManager {
    static let shared = CursorIndicatorManager()
    
    // Duration in seconds to display the indicator after a layout change
    var displayDuration: TimeInterval = 1.2
    
    private let window = CursorIndicatorWindow()
    private var dismissTimer: Timer?
    private var globalKeyMonitor: Any?
    private var localKeyMonitor: Any?
    private var isVisible = false
    
    private init() {
        setupInputSourceObserver()
    }
    
    func start() {
        updateImage()
    }
    
    func stop() {
        hide(animated: false)
    }
    
    func updateImage() {
        guard let source = InputSourceManager.shared.currentInputSource else { return }
        let flag = FlagProvider.shared.flagImage(for: source, size: CursorIndicatorWindow.windowSize)
        window.updateImage(flag)
    }
    
    private func setupInputSourceObserver() {
        NotificationCenter.default.addObserver(
            forName: InputSourceManager.inputSourceChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleInputSourceChanged()
        }
        
        NotificationCenter.default.addObserver(
            forName: Settings.settingsChangedNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if !Settings.shared.showCursorIndicator {
                self?.hide(animated: false)
            }
        }
    }
    
    func handleInputSourceChanged() {
        guard Settings.shared.showCursorIndicator else { return }
        
        updateImage()
        showIndicator(at: NSEvent.mouseLocation)
    }
    
    func showIndicator(at point: CGPoint) {
        // Invalidate any active dismissal timer
        dismissTimer?.invalidate()
        dismissTimer = nil
        
        window.show(near: point)
        isVisible = true
        
        // Listen for key strokes to immediately dismiss the HUD if typing begins
        setupKeyMonitorsIfNeeded()
        
        // Auto-dismiss after displayDuration
        dismissTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false) { [weak self] _ in
            self?.hide(animated: true)
        }
    }
    
    func hide(animated: Bool = true) {
        dismissTimer?.invalidate()
        dismissTimer = nil
        removeKeyMonitors()
        
        guard isVisible else { return }
        isVisible = false
        
        window.dismiss(animated: animated)
    }
    
    private func setupKeyMonitorsIfNeeded() {
        if globalKeyMonitor == nil {
            globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown]) { [weak self] _ in
                self?.hide(animated: false)
            }
        }
        if localKeyMonitor == nil {
            localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] event in
                self?.hide(animated: false)
                return event
            }
        }
    }
    
    private func removeKeyMonitors() {
        if let monitor = globalKeyMonitor {
            NSEvent.removeMonitor(monitor)
            globalKeyMonitor = nil
        }
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
            localKeyMonitor = nil
        }
    }
    
    func refreshMonitorsIfNeeded() {
        // Keep for AppDelegate compatibility
    }
    
    var isIndicatorVisible: Bool {
        return isVisible
    }
}
