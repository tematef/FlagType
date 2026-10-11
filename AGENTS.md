# FlagType — Agent Guidelines & Architecture

## Architecture & Frameworks
- **Pure AppKit & Carbon**: Zero third-party runtime dependencies. Uses native macOS `AppKit`, `Carbon.HIToolbox`, and `ServiceManagement`.
- **Standalone swiftc compilation**: The app builds via `swiftc` without requiring the full 12GB+ `Xcode.app`. Command Line Tools are sufficient. Run `./scripts/build.sh`.

## macOS System Integration Quirks
- **Cursor Detection**: `NSCursor.currentSystem` returns a new proxy object on every call in AppKit. Do NOT use pointer or value equality (`== NSCursor.iBeam`), as it always evaluates to `false`. Instead, inspect `cur.hotSpot` geometry:
  - Horizontal text I-beam: `round(x) == 4.0` and `round(y) >= 8.0 && round(y) <= 12.0` (typically `(4.0, 9.0)`).
  - Vertical text I-beam: `round(x) >= 6.0 && round(x) <= 8.0` and `round(y) == 4.0` (typically `(7.0, 4.0)`).
- **Background Agent Overlay (`LSUIElement = true`)**:
  - `window.orderFront(nil)` will NOT bring the window above active applications when called from an inactive agent app. Always use `window.orderFrontRegardless()`.
  - Window level must be elevated to `.popUpMenu` (level 101) or higher to avoid being obscured.
  - Include `.fullScreenAuxiliary` in `collectionBehavior` so overlays work on full-screen spaces.
- **Input Source Tracking**:
  - Carbon `TISCopyCurrentKeyboardInputSource` and distributed notification `kTISNotifySelectedKeyboardInputSourceChanged`.
  - Input source switching via `TISSelectInputSource`.

## Repository Scripts
- `scripts/build.sh`: Compiles and ad-hoc signs `build/FlagType.app`.
- `scripts/install.sh`: Deploys to `/Applications/FlagType.app` and strips `com.apple.quarantine`.
- `scripts/uninstall.sh`: Terminates app, cleans `/Applications/FlagType.app`, preferences plist, and caches.
- `scripts/generate_icon.swift`: Generates the modern macOS squircle icon set into `/tmp/FlagType.iconset`.
