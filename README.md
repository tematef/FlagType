# FlagType

**FlagType** is a fast, lightweight, and open-source macOS utility that displays your active keyboard layout flag right next to the cursor when hovering over text fields and in the menu bar. Never type in the wrong language again.

![macOS 13+](https://img.shields.io/badge/macOS-13.0%2B-blue)
![Apple Silicon](https://img.shields.io/badge/arch-arm64-orange)
![License: MIT](https://img.shields.io/badge/license-MIT-green)
![Tests](https://img.shields.io/badge/tests-passing-brightgreen)

---

## Features

- 🏳️ **Cursor Flag Indicator**: Displays the active keyboard layout flag next to the text pointer (I-beam) when editing or hovering over input fields.
- 📌 **Menu Bar Indicator**: Shows the active keyboard layout in the macOS menu bar.
- ⚡ **Instant Switching**: Switch between enabled keyboard layouts with a single click.
- ⌨️ **Smart Typing Detection**: Automatically hides the cursor indicator while actively typing to avoid distraction.
- 🚀 **Launch at Login**: Optional setting to automatically launch FlagType when logging in.
- 🪶 **Native & Lightweight**: Built 100% in pure Swift using AppKit and Carbon. Zero external dependencies, zero analytics, negligible CPU and battery footprint.

---

## Installation

### Option 1: One-Line Install (Recommended)

Run the following command in Terminal to download and install the latest release directly into `/Applications`:

```bash
curl -fsSL https://raw.githubusercontent.com/tematef/FlagType/main/scripts/install.sh | bash
```

---

### Option 2: Download from GitHub Releases

1. Download `FlagType.zip` from the latest [GitHub Releases](https://github.com/tematef/FlagType/releases).
2. Unzip `FlagType.zip` and move `FlagType.app` to your `/Applications` folder.
3. Open Terminal and remove the macOS quarantine attribute (since the app is ad-hoc signed without a paid Apple Developer certificate):
   ```bash
   xattr -d com.apple.quarantine /Applications/FlagType.app
   ```
4. Launch `FlagType.app` from `/Applications` or Spotlight.

---

### Option 3: Build from Source

FlagType builds directly using standard macOS Command Line Tools without requiring a full Xcode installation.

**Requirements**:
- macOS 13.0 (Ventura) or newer
- Apple Silicon Mac (`arm64`)
- Command Line Tools (`xcode-select --install`)

```bash
# Clone the repository
git clone https://github.com/tematef/FlagType.git
cd FlagType

# Run automated tests
./scripts/test.sh

# Build FlagType.app
./scripts/build.sh

# Install into /Applications
./scripts/install.sh
```

To create a distributable `.zip` release archive with SHA256 checksums:
```bash
./scripts/package.sh
```

---

## Testing

FlagType includes a fast, native Swift test runner covering unit tests and headless AppKit UI tests without requiring third-party testing tools:

```bash
./scripts/test.sh
```

The test suite verifies:
- Cursor geometry math and Retina/vertical I-beam detection
- Flag image resolution, language code normalization, and fallback text badge generation
- Settings persistence and toggles
- Headless AppKit window hierarchy and positioning offsets
- Menu bar status item initialization

---

## Corporate & Enterprise Usage

FlagType is designed to be fully compliant with corporate IT and enterprise security policies:

- **MIT License**: Free for personal, commercial, and enterprise use on company laptops.
- **100% Offline**: No network requests, telemetries, or remote analytics of any kind.
- **Built from Clean Source**: No bundled third-party binary blobs or precompiled libraries.
- **Accessibility Permissions**: macOS requires Accessibility access exclusively to query the system cursor position (`NSCursor.currentSystem`) and determine when the pointer hovers over text fields. FlagType does not log, inspect, or transmit user keystrokes.

---

## Permissions Setup

On first launch:
1. Open **System Settings** → **Privacy & Security** → **Accessibility**.
2. Toggle the switch for **FlagType**.
3. (Optional) If you want FlagType to start on boot, click the FlagType menu bar icon and select **Preferences** → **Launch at Login**.

---

## Uninstallation

To completely remove FlagType, its preferences, and any launch agent configurations:

```bash
./scripts/uninstall.sh
```

---

## License

Distributed under the [MIT License](LICENSE).
