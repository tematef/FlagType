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
    
    private func checkAccessibilityPermissions() {
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true] as CFDictionary
        let isTrusted = AXIsProcessTrustedWithOptions(options)
        if !isTrusted {
            print("[FlagType] Accessibility permissions not yet granted. Prompt displayed.")
        }
    }
}
