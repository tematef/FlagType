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

echo "==> Verifying repository cleanliness (zero YouType / legacy references)..."
if git grep -qi "youtype" -- ':!scripts/test.sh' ':!.agents/rules' ':!docs/plans'; then
    echo "ERROR: Found references to 'YouType' in repository!"
    exit 1
fi
if git grep -qi "korotkov" -- ':!scripts/test.sh'; then
    echo "ERROR: Found references to 'Korotkov' in repository!"
    exit 1
fi
if git grep -qi "freefelt" -- ':!scripts/test.sh'; then
    echo "ERROR: Found references to 'freefelt' in repository!"
    exit 1
fi

echo "==> Cleanliness check passed: zero legacy references found."
