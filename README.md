# FlagType

**FlagType** is a lightweight, open-source macOS menu bar utility that displays your active keyboard layout as a flag right next to the cursor when hovering over text fields. Never type in the wrong language again.

![macOS 13+](https://img.shields.io/badge/macOS-13.0%2B-blue)
![License](https://img.shields.io/badge/license-MIT-green)

---

## Features

- 🏳️ **Cursor Flag Indicator**: Shows the active keyboard layout flag next to the pointer when typing or hovering over input fields.
- 📌 **Menu Bar Integration**: Displays the current language flag in the macOS menu bar for at-a-glance awareness.
- ⚡ **Instant Switching**: Click the status item to switch between all enabled input sources.
- ⌨️ **Smart Typing Detection**: Automatically hides the flag indicator while typing to keep your screen distraction-free.
- 🚀 **Launch at Login**: Easily start FlagType automatically when logging into macOS.
- 🪶 **Lightweight & Native**: Built with pure AppKit — negligible CPU and battery usage.

---

## Installation

### Option 1: Quick Install (Local)

Clone the repository and run the build and install scripts:

```bash
git clone https://github.com/your-username/FlagType.git
cd FlagType
./scripts/build.sh
./scripts/install.sh
```

### Option 2: Build from Source

Requirements: macOS 13.0+ and Command Line Tools (`xcode-select --install`).

```bash
./scripts/build.sh
```

The compiled `FlagType.app` will be created inside the `build/` directory.

---

## Permissions

FlagType requires **Accessibility** permission in macOS to track the cursor location and detect text inputs across applications.

On the first launch:
1. Open **System Settings** → **Privacy & Security** → **Accessibility**.
2. Toggle on **FlagType**.

---

## Uninstallation

To cleanly remove FlagType and its preferences:

```bash
./scripts/uninstall.sh
```

---

## License

This project is licensed under the [MIT License](LICENSE).
