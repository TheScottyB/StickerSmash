#!/bin/bash
# Script to connect an existing Expo/React Native app to EAS

# Define text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display header
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  Connect Existing App to EAS  ${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Step 1: Verify the app.json file
echo -e "${YELLOW}Step 1: Checking app.json configuration...${NC}"
if [ -f "../app.json" ]; then
  echo -e "  ✅ ${GREEN}app.json exists${NC}"
  
  # Check critical fields
  app_name=$(grep -o '"name": "[^"]*"' ../app.json | head -1 | cut -d'"' -f4)
  app_slug=$(grep -o '"slug": "[^"]*"' ../app.json | head -1 | cut -d'"' -f4)
  
  if [ -z "$app_name" ]; then
    echo -e "  ❌ ${RED}No name found in app.json${NC}"
    echo -e "  ${YELLOW}Please add a name to your app.json file${NC}"
  else
    echo -e "  ✅ ${GREEN}App name: $app_name${NC}"
  fi
  
  if [ -z "$app_slug" ]; then
    echo -e "  ❌ ${RED}No slug found in app.json${NC}"
    echo -e "  ${YELLOW}Please add a slug to your app.json file${NC}"
  else
    echo -e "  ✅ ${GREEN}App slug: $app_slug${NC}"
  fi
  
  # Check if project ID already exists
  project_id=$(grep -o '"projectId": "[^"]*"' ../app.json | cut -d'"' -f4)
  if [ -n "$project_id" ]; then
    echo -e "  ℹ️ ${YELLOW}Project ID already exists: $project_id${NC}"
    echo -e "  ${YELLOW}You may already be connected to EAS${NC}"
  fi
else
  echo -e "  ❌ ${RED}app.json not found${NC}"
  echo -e "  ${YELLOW}Please create an app.json file with name and slug properties${NC}"
  exit 1
fi
echo ""

# Step 2: Check for Expo SDK and EAS CLI
echo -e "${YELLOW}Step 2: Checking for Expo SDK and EAS CLI...${NC}"
if grep -q '"expo":' ../package.json; then
  echo -e "  ✅ ${GREEN}Expo SDK found in package.json${NC}"
else
  echo -e "  ❌ ${RED}Expo SDK not found in package.json${NC}"
  echo -e "  ${YELLOW}This doesn't appear to be an Expo project${NC}"
  exit 1
fi

if command -v eas &> /dev/null; then
  eas_version=$(eas --version)
  echo -e "  ✅ ${GREEN}EAS CLI is installed (version: $eas_version)${NC}"
else
  echo -e "  ❌ ${RED}EAS CLI not found. Installing...${NC}"
  npm install -g eas-cli
fi
echo ""

# Step 3: Login to Expo
echo -e "${YELLOW}Step 3: Logging in to Expo...${NC}"
echo -e "  ${BLUE}Executing: npx eas-cli@latest login${NC}"
npx eas-cli@latest login
if [ $? -ne 0 ]; then
  echo -e "  ❌ ${RED}Failed to login to Expo${NC}"
  exit 1
else
  echo -e "  ✅ ${GREEN}Successfully logged in to Expo${NC}"
fi
echo ""

# Step 4: Initialize EAS for the existing project
echo -e "${YELLOW}Step 4: Initializing EAS for your existing app...${NC}"
echo -e "  ${BLUE}Two options available:${NC}"
echo -e ""
echo -e "  Option 1: Non-interactive (Recommended for automation)"
echo -e "  ${BLUE}Executing: npx eas-cli@latest init --non-interactive --force${NC}"
echo -e ""
echo -e "  Option 2: Interactive (More control, requires terminal input)"
echo -e "  ${BLUE}Executing: npx eas-cli@latest init${NC}"
echo ""
echo -e "  ${YELLOW}Based on our research, non-interactive mode works well for automation${NC}"
echo -e "  ${YELLOW}and avoids issues with accounts that have historical configurations.${NC}"
echo ""
read -p "Which option do you prefer? (1/2, default: 1): " choice

if [ "$choice" == "2" ]; then
  echo -e "  ${BLUE}Executing: npx eas-cli@latest init${NC}"
  npx eas-cli@latest init
else
  echo -e "  ${BLUE}Executing: npx eas-cli@latest init --non-interactive --force${NC}"
  npx eas-cli@latest init --non-interactive --force
fi

if [ $? -ne 0 ]; then
  echo -e "  ❌ ${RED}Failed to initialize EAS project${NC}"
  echo -e "  ${YELLOW}Try the other option or check your account configuration${NC}"
  exit 1
else
  echo -e "  ✅ ${GREEN}Successfully initialized EAS project${NC}"
fi
echo ""

# Step 5: Verify project ID was added
echo -e "${YELLOW}Step 5: Verifying project ID was added to app.json...${NC}"
project_id_after=$(grep -o '"projectId": "[^"]*"' ../app.json | cut -d'"' -f4)
if [ -n "$project_id_after" ]; then
  echo -e "  ✅ ${GREEN}Project ID added: $project_id_after${NC}"
  if [ "$project_id" != "$project_id_after" ] && [ -n "$project_id" ]; then
    echo -e "  ℹ️ ${YELLOW}Note: Project ID has changed from $project_id to $project_id_after${NC}"
  fi
else
  echo -e "  ❌ ${RED}No project ID found in app.json after initialization${NC}"
  echo -e "  ${YELLOW}You may need to manually add the project ID to app.json${NC}"
  echo -e "  ${YELLOW}Check the Expo dashboard for your project ID${NC}"
fi
echo ""

# Step 6: Check project info
echo -e "${YELLOW}Step 6: Verifying project connection...${NC}"
echo -e "  ${BLUE}Executing: npx eas-cli@latest project:info${NC}"
npx eas-cli@latest project:info
echo ""

# Final instructions
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  Next Steps  ${NC}"
echo -e "${BLUE}====================================${NC}"
echo -e "1. ${RED}CRITICAL STEP:${NC} Go to ${GREEN}https://expo.dev${NC} and:"
echo -e "   a. Find your newly connected project"
echo -e "   b. ${RED}Manually connect your GitHub repository${NC} (required for EAS Workflows)"
echo -e "   c. Install the Expo GitHub app when prompted"
echo -e "2. To verify your connection is working, run:"
echo -e "   ${GREEN}npx eas-cli@latest build:configure${NC}"
echo -e "3. To try a build, run:"
echo -e "   ${GREEN}npx eas-cli@latest build --platform ios --profile development${NC}"
echo -e ""
echo -e "${RED}IMPORTANT:${NC} If you encounter issues due to historical account configurations,"
echo -e "try the Hub approach using the Expo web dashboard as documented in ${GREEN}HUB-APPROACH-GUIDE.md${NC}"
echo -e ""
echo -e "See ${GREEN}CONNECTING-EXISTING-APP.md${NC} for detailed troubleshooting guidance"
echo -e ""
echo -e "${YELLOW}Good luck with your deployment!${NC}"