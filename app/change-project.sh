#!/bin/bash
# Script to update the EAS project ID

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Move to project root
cd ..

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
TMP_FILE=$(mktemp)
jq --arg owner "$OWNER" --arg projectId "$NEW_PROJECT_ID" '.expo.owner = $owner | .expo.extra.eas.projectId = $projectId' app.json > "$TMP_FILE"
mv "$TMP_FILE" app.json

# Set the account to use for initialization
echo -e "${YELLOW}Setting account to $OWNER...${NC}"
npx eas-cli account:switch --account $OWNER

# Create the new project
echo -e "${YELLOW}Creating new project $NEW_PROJECT_ID under $OWNER...${NC}"
npx eas-cli project:create --id $NEW_PROJECT_ID --title "MyStickersApp" --non-interactive

# Link the current project to the new project
echo -e "${YELLOW}Linking current project to the new EAS project...${NC}"
npx eas-cli project:link --id $NEW_PROJECT_ID --non-interactive

echo -e "${GREEN}Project successfully updated!${NC}"
echo -e "${YELLOW}New project ID: $NEW_PROJECT_ID${NC}"
echo -e "${YELLOW}Owner: $OWNER${NC}"

# Verify the changes
echo -e "${YELLOW}Verifying project configuration...${NC}"
npx eas-cli project:info