#!/bin/bash
# Script to update the EAS project ID

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Store the current directory and move to project root
SCRIPT_DIR=$(pwd)
cd ..
PROJECT_ROOT=$(pwd)
echo -e "${YELLOW}Project root: ${PROJECT_ROOT}${NC}"

# Get current account info
echo -e "${YELLOW}Current account information:${NC}"
npx eas-cli whoami

# Prompt for which organization to use
echo -e "\n${YELLOW}Which organization would you like to use?${NC}"
echo -e "1) thescottybe"
echo -e "2) avallon-technologies-llc"
echo -e "3) tbdadmin"
echo -e "4) jeff.avallon.technologies"
echo -e "5) djscottyb"
read -r ORG_CHOICE

case $ORG_CHOICE in
  1) OWNER="thescottybe" ;;
  2) OWNER="avallon-technologies-llc" ;;
  3) OWNER="tbdadmin" ;;
  4) OWNER="jeff.avallon.technologies" ;;
  5) OWNER="djscottyb" ;;
  *) echo -e "${RED}Invalid choice. Exiting.${NC}"; exit 1 ;;
esac

# Generate a new project ID
NEW_PROJECT_ID="mystickers-$(date +%s)"

# Update app.json with the new project ID and owner
echo -e "${YELLOW}Updating app.json with new project ID and owner...${NC}"
APP_JSON_PATH="${PROJECT_ROOT}/app.json"
echo -e "${YELLOW}App.json path: ${APP_JSON_PATH}${NC}"
TMP_FILE=$(mktemp)
jq --arg owner "$OWNER" --arg projectId "$NEW_PROJECT_ID" '.expo.owner = $owner | .expo.extra.eas.projectId = $projectId' "${APP_JSON_PATH}" > "$TMP_FILE"
mv "$TMP_FILE" "${APP_JSON_PATH}"

# Initialize the project using eas init instead of the individual commands
echo -e "${YELLOW}Initializing project under $OWNER...${NC}"
npx eas-cli init --non-interactive --id $NEW_PROJECT_ID

echo -e "${GREEN}Project successfully updated!${NC}"
echo -e "${YELLOW}New project ID: $NEW_PROJECT_ID${NC}"
echo -e "${YELLOW}Owner: $OWNER${NC}"

# Run a build to update the app configuration
echo -e "${YELLOW}Would you like to run a development build to test the new configuration? (y/n)${NC}"
read -r RUN_BUILD

if [[ $RUN_BUILD == "y" ]]; then
  echo -e "${YELLOW}Starting development build for iOS simulator...${NC}"
  npx eas-cli build --platform ios --profile development --non-interactive
else
  echo -e "${YELLOW}Skipping build test. You can run trigger-deployment.sh when ready.${NC}"
fi