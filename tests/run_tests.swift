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

    static func isHotSpotIBeam(x: Double, y: Double) -> Bool {
        let rx = round(x)
        let ry = round(y)
        if rx == 4.0 && (ry >= 8.0 && ry <= 12.0) { return true }
        if (rx >= 6.0 && rx <= 8.0) && ry == 4.0 { return true }
        return false
    }

    static func main() {
        // Initialize NSApplication in headless mode
        _ = NSApplication.shared

        testGroup("Cursor Geometry Unit Tests") {
            assertTrue(isHotSpotIBeam(x: 4.0, y: 9.0), "Standard Retina text I-beam (4.0, 9.0) recognized")
            assertTrue(isHotSpotIBeam(x: 4.0, y: 8.0), "Standard text I-beam variant (4.0, 8.0) recognized")
            assertTrue(isHotSpotIBeam(x: 4.0, y: 11.0), "High-res text I-beam (4.0, 11.0) recognized")
            assertTrue(isHotSpotIBeam(x: 7.0, y: 4.0), "Vertical layout I-beam (7.0, 4.0) recognized")
            
            assertTrue(!isHotSpotIBeam(x: 4.0, y: 4.0), "Standard arrow cursor (4.0, 4.0) rejected")
            assertTrue(!isHotSpotIBeam(x: 0.0, y: 0.0), "Zero hotspot cursor (0.0, 0.0) rejected")
            assertTrue(!isHotSpotIBeam(x: 6.0, y: 1.0), "Pointing hand cursor (6.0, 1.0) rejected")
            assertTrue(!isHotSpotIBeam(x: 8.0, y: 8.0), "Crosshair/resize cursor (8.0, 8.0) rejected")
        }

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
            
            let initialTyping = Settings.shared.hideWhileTyping
            Settings.shared.hideWhileTyping = true
            assertTrue(Settings.shared.hideWhileTyping, "Settings hideWhileTyping can be set to true")
            Settings.shared.hideWhileTyping = initialTyping
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
        }

        testGroup("Headless AppKit UI Tests: MenuManager") {
            let menuManager = MenuManager.shared
            menuManager.setup()
            menuManager.updateStatusItem()
            
            let sources = InputSourceManager.shared.availableInputSources()
            assertTrue(!sources.isEmpty, "InputSourceManager lists available input sources on system")
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

