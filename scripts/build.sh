#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

APP_DIR="build/FlagType.app"
CONTENTS_DIR="$APP_DIR/Contents"
MACOS_DIR="$CONTENTS_DIR/MacOS"
RESOURCES_DIR="$CONTENTS_DIR/Resources"

echo "==> Cleaning previous build..."
rm -rf build
mkdir -p "$MACOS_DIR" "$RESOURCES_DIR"

echo "==> Compiling Swift sources..."
swiftc \
    -O \
    -target arm64-apple-macosx13.0 \
    -framework AppKit \
    -framework Carbon \
    -framework ServiceManagement \
    -o "$MACOS_DIR/FlagType" \
    FlagType/main.swift \
    FlagType/AppDelegate.swift \
    FlagType/Core/Settings.swift \
    FlagType/Core/InputSourceManager.swift \
    FlagType/Core/FlagProvider.swift \
    FlagType/UI/CursorIndicatorWindow.swift \
    FlagType/UI/CursorIndicatorManager.swift \
    FlagType/UI/MenuManager.swift

echo "==> Copying Info.plist..."
cp FlagType/Info.plist "$CONTENTS_DIR/Info.plist"

echo "==> Copying resources..."
if [ -f FlagType/Resources/AppIcon.icns ]; then
    cp FlagType/Resources/AppIcon.icns "$RESOURCES_DIR/AppIcon.icns"
fi

if [ -d FlagType/Resources/Flags ]; then
    cp -R FlagType/Resources/Flags "$RESOURCES_DIR/"
fi

echo "==> Ad-hoc code signing..."
codesign --force --deep --sign - "$APP_DIR"

echo "==> Done! App built at: $APP_DIR"
