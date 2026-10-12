# FlagType — Agent Guidelines & Architecture

## Architecture & Frameworks
- **Pure AppKit & Carbon**: Zero third-party runtime dependencies. Uses native macOS `AppKit`, `Carbon.HIToolbox`, and `ServiceManagement`.
- **Standalone swiftc compilation**: The app builds via `swiftc` without requiring the full 12GB+ `Xcode.app`. Command Line Tools are sufficient. Run `./scripts/build.sh`.

## macOS System Integration Quirks
- **Cursor Detection & Web Browser Limitations**:
  - `NSCursor.currentSystem` returns a new proxy object on every call in AppKit. Do NOT use pointer or value equality (`== NSCursor.iBeam`).
  - Browsers (Safari, Chrome, Firefox) and PDF viewers set `currentSystem` to an I-beam over all selectable static text, not just editable inputs.
  - Accessibility hit-testing (`AXUIElementCopyElementAtPosition`) inside web renderers is fragile across sandboxes and DOM wrapper roles (`AXGroup`, `AXWebArea`, `AXStaticText`).
  - **Architecture Decision**: Avoid continuous hover polling or accessibility hit-testing. Rely on event-driven notifications (`kTISNotifySelectedKeyboardInputSourceChanged`) to briefly display the indicator HUD upon layout switch, and auto-dismiss.
- **Ephemeral Event Monitors for HUD Dismissal**:
  - Rather than running 24/7 global event taps or continuous polling loops, attach `NSEvent.addGlobalMonitorForEvents(matching: [.keyDown])` dynamically only while the temporary HUD window is on screen.
  - Tear down monitors immediately upon keystroke dismissal or auto-dismiss timer expiration to eliminate idle overhead and trackpad jitter issues.
- **Background Agent Overlay (`LSUIElement = true`)**:
  - `window.orderFront(nil)` will NOT bring the window above active applications when called from an inactive agent app. Always use `window.orderFrontRegardless()`.
  - Window level must be elevated to `.popUpMenu` (level 101) or higher to avoid being obscured.
  - Include `.fullScreenAuxiliary` in `collectionBehavior` so overlays work on full-screen spaces.
- **Input Source Tracking**:
  - Carbon `TISCopyCurrentKeyboardInputSource` and distributed notification `kTISNotifySelectedKeyboardInputSourceChanged`.
  - Input source switching via `TISSelectInputSource`.

## Repository Scripts
- `scripts/test.sh`: Compiles and executes native Swift unit and headless UI test runner.
- `scripts/build.sh`: Compiles and ad-hoc signs `build/FlagType.app`.
- `scripts/package.sh`: Runs test suite, builds release binary, and packages `build/FlagType.zip` with `SHA256SUMS.txt`.
- `scripts/install.sh`: Deploys to `/Applications/FlagType.app` (supports local build or remote GitHub release download) and strips `com.apple.quarantine`.
- `scripts/uninstall.sh`: Terminates app, cleans `/Applications/FlagType.app`, preferences plist, and caches.
- `scripts/generate_icon.swift`: Generates the modern macOS squircle icon set into `/tmp/FlagType.iconset`.

## Multi-file Swift Compilation Quirk
- When compiling multiple files using `swiftc` without Xcode, top-level statements are prohibited outside `main.swift`. Test runners and standalone entry points spanning multiple source files must use `@main struct TestRunner { static func main() { ... } }`.

