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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_APP="$SCRIPT_DIR/../build/${APP_NAME}.app"

printf "${CYAN}============================ Installing ${APP_NAME} =============================\n${NOCOLOR}"

# Kill running instance if any
pkill -x "$APP_NAME" 2>/dev/null || true

if [ -d "$LOCAL_APP" ]; then
    printf "${WHITE}- Installing local build from ${YELLOW}$LOCAL_APP\n${NOCOLOR}"
    rm -rf "$APP_DESTINATION"
    cp -R "$LOCAL_APP" "$APP_DESTINATION"
else
    printf "${RED}Local build not found at $LOCAL_APP. Please run ./scripts/build.sh first.\n${NOCOLOR}"
    exit 1
fi

printf "${WHITE}- Removing quarantine attribute... ${NOCOLOR}"
xattr -r -d com.apple.quarantine "$APP_DESTINATION" 2>/dev/null || true
printf "${GREEN}DONE\n${NOCOLOR}"

printf "${GREEN}${APP_NAME} installed successfully to ${APP_DESTINATION}!\n${NOCOLOR}"
printf "${WHITE}Launching ${APP_NAME}...\n${NOCOLOR}"
open "$APP_DESTINATION"

printf "${CYAN}=============================================================================\n${NOCOLOR}"
