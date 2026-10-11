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
BUNDLE_ID="com.flagtype.FlagType"
PLIST_FILE="$HOME/Library/Preferences/${BUNDLE_ID}.plist"

printf "${CYAN}=========================== Uninstalling ${APP_NAME} ============================\n${NOCOLOR}"

# Quit application
printf "${WHITE}- Stopping ${APP_NAME} if running... ${NOCOLOR}"
pkill -x "$APP_NAME" 2>/dev/null || true
printf "${GREEN}DONE\n${NOCOLOR}"

# Remove App
if [ -d "$APP_DESTINATION" ]; then
    printf "${WHITE}- Removing ${YELLOW}$APP_DESTINATION... ${NOCOLOR}"
    rm -rf "$APP_DESTINATION"
    printf "${GREEN}DONE\n${NOCOLOR}"
else
    printf "${YELLOW}${APP_DESTINATION} is not installed.\n${NOCOLOR}"
fi

# Remove Preferences
if [ -f "$PLIST_FILE" ]; then
    printf "${WHITE}- Removing preferences ${YELLOW}$PLIST_FILE... ${NOCOLOR}"
    rm -f "$PLIST_FILE"
    printf "${GREEN}DONE\n${NOCOLOR}"
fi

printf "${CYAN}=============================================================================\n${NOCOLOR}"
printf "${GREEN}${APP_NAME} has been completely uninstalled.\n${NOCOLOR}"
