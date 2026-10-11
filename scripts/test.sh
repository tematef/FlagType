#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Building and running FlagType test suite..."

mkdir -p build

swiftc \
    -O \
    -target arm64-apple-macosx13.0 \
    -framework AppKit \
    -framework Carbon \
    -framework ServiceManagement \
    -o build/test_runner \
    FlagType/Core/Settings.swift \
    FlagType/Core/InputSourceManager.swift \
    FlagType/Core/FlagProvider.swift \
    FlagType/UI/CursorIndicatorWindow.swift \
    FlagType/UI/CursorIndicatorManager.swift \
    FlagType/UI/MenuManager.swift \
    tests/run_tests.swift

./build/test_runner
rm -f build/test_runner
