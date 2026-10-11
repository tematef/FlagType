#!/bin/bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Step 1/3: Running test suite..."
./scripts/test.sh

echo "==> Step 2/3: Building FlagType.app..."
./scripts/build.sh

echo "==> Step 3/3: Packaging Release zip and computing checksum..."
cd build
ditto -c -k --sequesterRsrc --keepParent FlagType.app FlagType.zip
shasum -a 256 FlagType.zip > SHA256SUMS.txt

echo "==> Release package ready:"
ls -lh FlagType.zip SHA256SUMS.txt
cat SHA256SUMS.txt
