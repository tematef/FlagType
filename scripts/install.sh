#!/bin/bash
set -euo pipefail

RED='\033[1;31m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[0;33m'
WHITE='\033[1;37m'
NOCOLOR='\033[0m'

APP_NAME="FlagType"
APP_DESTINATION="/Applications/${APP_NAME}.app"
GITHUB_REPO="${FLAGTYPE_REPO:-freefelt/FlagType}"

printf "${CYAN}============================ Installing ${APP_NAME} =============================\n${NOCOLOR}"

# Kill running instance if any
pkill -x "$APP_NAME" 2>/dev/null || true

# Determine install source
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || echo "")"
LOCAL_APP=""

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/../build/${APP_NAME}.app" ]; then
    LOCAL_APP="$SCRIPT_DIR/../build/${APP_NAME}.app"
fi

if [ -n "$LOCAL_APP" ] && [ -d "$LOCAL_APP" ]; then
    printf "${WHITE}- Installing local build from ${YELLOW}$LOCAL_APP\n${NOCOLOR}"
    rm -rf "$APP_DESTINATION"
    cp -R "$LOCAL_APP" "$APP_DESTINATION"
else
    printf "${WHITE}- Downloading latest release from GitHub (${GITHUB_REPO})...\n${NOCOLOR}"
    TMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TMP_DIR"' EXIT
    
    DOWNLOAD_URL="https://github.com/${GITHUB_REPO}/releases/latest/download/${APP_NAME}.zip"
    curl -fSL "$DOWNLOAD_URL" -o "$TMP_DIR/${APP_NAME}.zip" || {
        printf "${RED}Failed to download ${APP_NAME}.zip from ${DOWNLOAD_URL}.\n${NOCOLOR}"
        printf "${YELLOW}If building from source, run: ./scripts/build.sh first.\n${NOCOLOR}"
        exit 1
    }
    
    printf "${WHITE}- Extracting to /Applications...\n${NOCOLOR}"
    rm -rf "$APP_DESTINATION"
    ditto -x -k "$TMP_DIR/${APP_NAME}.zip" /Applications/
fi

printf "${WHITE}- Removing quarantine attribute... ${NOCOLOR}"
xattr -r -d com.apple.quarantine "$APP_DESTINATION" 2>/dev/null || true
printf "${GREEN}DONE\n${NOCOLOR}"

printf "${GREEN}${APP_NAME} installed successfully to ${APP_DESTINATION}!\n${NOCOLOR}"
printf "${WHITE}Launching ${APP_NAME}...\n${NOCOLOR}"
open "$APP_DESTINATION"

printf "${CYAN}=============================================================================\n${NOCOLOR}"
