import AppKit

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Setup menu bar item and cursor tracking
        MenuManager.shared.setup()
        CursorIndicatorManager.shared.start()
        
        // Check accessibility permissions for global mouse/key events
        checkAccessibilityPermissions()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        CursorIndicatorManager.shared.stop()
    }
    
    private var accessibilityCheckTimer: Timer?
    
    private func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        if !isTrusted {
            print("[FlagType] Accessibility permissions not yet granted. Prompt displayed.")
            // Periodically check until granted so event taps attach without restarting app
            accessibilityCheckTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: true) { [weak self] timer in
                if AXIsProcessTrusted() {
                    print("[FlagType] Accessibility permissions granted.")
                    timer.invalidate()
                    self?.accessibilityCheckTimer = nil
                    CursorIndicatorManager.shared.refreshMonitorsIfNeeded()
                }
            }
        }
    }
}
