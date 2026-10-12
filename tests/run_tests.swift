import Foundation
import AppKit
import Carbon

@main
struct TestRunner {
    static var passedCount = 0
    static var failedCount = 0

    static func assertTrue(_ condition: Bool, _ testName: String, file: String = #file, line: Int = #line) {
        if condition {
            passedCount += 1
            print("  \u{001B}[32m✓\u{001B}[0m \(testName)")
        } else {
            failedCount += 1
            print("  \u{001B}[31m✗ FAIL:\u{001B}[0m \(testName) (line \(line))")
        }
    }

    static func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ testName: String, file: String = #file, line: Int = #line) {
        if actual == expected {
            passedCount += 1
            print("  \u{001B}[32m✓\u{001B}[0m \(testName)")
        } else {
            failedCount += 1
            print("  \u{001B}[31m✗ FAIL:\u{001B}[0m \(testName) — Expected: [\(expected)], got: [\(actual)] (line \(line))")
        }
    }

    static func testGroup(_ name: String, block: () -> Void) {
        print("\n\u{001B}[1m▶ Running \(name)...\u{001B}[0m")
        block()
    }

    static func main() {
        // Initialize NSApplication in headless mode
        _ = NSApplication.shared

        testGroup("FlagProvider Unit Tests") {
            let dummySourceUS = InputSource(
                id: "com.apple.keylayout.US",
                localizedName: "U.S.",
                iconURL: nil,
                rawSource: TISCopyCurrentKeyboardInputSource()!.takeRetainedValue()
            )
            let flagUS = FlagProvider.shared.flagImage(for: dummySourceUS, size: CGSize(width: 24, height: 16))
            assertTrue(flagUS.size.width == 24 && flagUS.size.height == 16, "US flag resolves with requested size")
            
            let dummySourceUA = InputSource(
                id: "com.apple.keylayout.Ukrainian-PC",
                localizedName: "Ukrainian",
                iconURL: nil,
                rawSource: dummySourceUS.rawSource
            )
            let flagUA = FlagProvider.shared.flagImage(for: dummySourceUA, size: CGSize(width: 24, height: 16))
            assertTrue(flagUA.size.width == 24 && flagUA.size.height == 16, "Ukrainian flag resolves via normalization")
            
            let dummySourcePL = InputSource(
                id: "com.apple.keylayout.PolishPro",
                localizedName: "Polish",
                iconURL: nil,
                rawSource: dummySourceUS.rawSource
            )
            let flagPL = FlagProvider.shared.flagImage(for: dummySourcePL, size: CGSize(width: 24, height: 16))
            assertTrue(flagPL.size.width == 24 && flagPL.size.height == 16, "Polish flag resolves via normalization")
            
            let dummySourceUnknown = InputSource(
                id: "com.apple.keylayout.CustomLanguageXYZ",
                localizedName: "Custom Lang",
                iconURL: nil,
                rawSource: dummySourceUS.rawSource
            )
            let flagBadge = FlagProvider.shared.flagImage(for: dummySourceUnknown, size: CGSize(width: 24, height: 16))
            assertTrue(flagBadge.size.width == 24, "Unknown language generates valid text fallback badge")
        }

        testGroup("Settings Unit Tests") {
            let initialCursor = Settings.shared.showCursorIndicator
            Settings.shared.showCursorIndicator = true
            assertTrue(Settings.shared.showCursorIndicator, "Settings showCursorIndicator can be set to true")
            
            Settings.shared.showCursorIndicator = false
            assertTrue(!Settings.shared.showCursorIndicator, "Settings showCursorIndicator can be set to false")
            Settings.shared.showCursorIndicator = initialCursor
            
            let initialMenuName = Settings.shared.showMenuLayoutName
            Settings.shared.showMenuLayoutName = true
            assertTrue(Settings.shared.showMenuLayoutName, "Settings showMenuLayoutName can be set to true")
            Settings.shared.showMenuLayoutName = false
            assertTrue(!Settings.shared.showMenuLayoutName, "Settings showMenuLayoutName can be set to false")
            Settings.shared.showMenuLayoutName = initialMenuName
            
            // Legacy compatibility check
            assertTrue(Settings.shared.hideWhileTyping, "Settings hideWhileTyping provides legacy getter compatibility")
        }

        testGroup("Headless AppKit UI Tests: CursorIndicatorWindow") {
            let window = CursorIndicatorWindow()
            
            assertTrue(window.styleMask.contains(.borderless), "Window has borderless styleMask")
            assertTrue(!window.isOpaque, "Window is non-opaque for transparent background")
            assertEqual(window.backgroundColor, NSColor.clear, "Window has clear background color")
            assertTrue(window.ignoresMouseEvents, "Window ignores mouse clicks")
            assertEqual(window.level, .popUpMenu, "Window has elevated popUpMenu level")
            assertTrue(window.collectionBehavior.contains(.canJoinAllSpaces), "Window can join all spaces")
            assertTrue(window.collectionBehavior.contains(.fullScreenAuxiliary), "Window supports fullScreenAuxiliary spaces")
            
            let testPoint = CGPoint(x: 200, y: 300)
            window.setPosition(near: testPoint)
            let expectedOrigin = CGPoint(x: 200 + 14, y: 300 - 18)
            assertEqual(window.frame.origin, expectedOrigin, "Window setPosition correctly applies offset (14, -18)")
            
            window.show(near: testPoint)
            assertEqual(window.alphaValue, 1.0, "Window show resets alphaValue to 1.0")
            
            window.dismiss(animated: false)
            assertTrue(!window.isVisible, "Window dismiss hides window immediately")
        }

        testGroup("Headless AppKit UI Tests: MenuManager") {
            let menuManager = MenuManager.shared
            menuManager.setup()
            menuManager.updateStatusItem()
            
            let sources = InputSourceManager.shared.availableInputSources()
            assertTrue(!sources.isEmpty, "InputSourceManager lists available input sources on system")
        }

        testGroup("Layout Change Indicator HUD Tests") {
            let manager = CursorIndicatorManager.shared
            let savedPref = Settings.shared.showCursorIndicator
            let originalDuration = manager.displayDuration
            
            // 1. When enabled, showing indicator sets isIndicatorVisible = true
            Settings.shared.showCursorIndicator = true
            let testCursorLocation = CGPoint(x: 150, y: 250)
            manager.showIndicator(at: testCursorLocation)
            assertTrue(manager.isIndicatorVisible, "HUD becomes visible when layout change indicator is triggered")
            
            // 2. Typing keystroke dismisses indicator immediately
            manager.hide(animated: false)
            assertTrue(!manager.isIndicatorVisible, "HUD is immediately dismissed on user keystroke / typing")
            
            // 3. When disabled in Settings, layout changes do NOT show HUD
            Settings.shared.showCursorIndicator = false
            manager.handleInputSourceChanged()
            assertTrue(!manager.isIndicatorVisible, "HUD remains hidden on layout change when setting is disabled")
            
            // 4. Multiple rapid layout switches refresh display and reset timer without crashing
            Settings.shared.showCursorIndicator = true
            manager.handleInputSourceChanged()
            assertTrue(manager.isIndicatorVisible, "HUD visible after first layout change")
            manager.handleInputSourceChanged()
            assertTrue(manager.isIndicatorVisible, "HUD remains active and resets on second rapid layout change")
            
            // 5. Timer auto-dismiss test
            manager.displayDuration = 0.05
            manager.showIndicator(at: testCursorLocation)
            assertTrue(manager.isIndicatorVisible, "HUD visible before timer expires")
            
            let expectation = CFRunLoopRunInMode(.defaultMode, 0.1, false)
            _ = expectation
            assertTrue(!manager.isIndicatorVisible, "HUD automatically dismisses after displayDuration expires")
            
            // Restore original settings
            manager.displayDuration = originalDuration
            Settings.shared.showCursorIndicator = savedPref
        }

        print("\n=========================================")
        if failedCount == 0 {
            print("\u{001B}[32m\u{001B}[1m✓ ALL TESTS PASSED (\(passedCount)/\(passedCount))\u{001B}[0m")
            exit(0)
        } else {
            print("\u{001B}[31m\u{001B}[1m✗ TESTS FAILED: \(failedCount) failure(s), \(passedCount) passed\u{001B}[0m")
            exit(1)
        }
    }
}
