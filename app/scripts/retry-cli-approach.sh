#!/bin/bash
# Script to retry the EAS CLI approach using official documentation steps

# Define text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display header
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}    EAS CLI Approach Retry    ${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Step 1: Verify project exists
echo -e "${YELLOW}Step 1: Verifying project exists...${NC}"
if [ -f "../app.json" ]; then
  echo -e "  ✅ ${GREEN}Project exists${NC}"
else
  echo -e "  ❌ ${RED}Project not found. Create a new project:${NC}"
  echo -e "  ${BLUE}npx create-expo-app@latest${NC}"
  exit 1
fi
echo ""

# Step 2: Login to EAS
echo -e "${YELLOW}Step 2: Logging in to EAS...${NC}"
echo -e "  ${BLUE}Executing: npx eas-cli@latest login${NC}"
npx eas-cli@latest login
if [ $? -ne 0 ]; then
  echo -e "  ❌ ${RED}Failed to login to EAS${NC}"
  exit 1
else
  echo -e "  ✅ ${GREEN}Successfully logged in to EAS${NC}"
fi
echo ""

# Step 3: Initialize EAS project
echo -e "${YELLOW}Step 3: Initializing EAS project...${NC}"
echo -e "  ${BLUE}Executing: npx eas-cli@latest init${NC}"
echo -e "  ${YELLOW}Note: This will require interactive prompts. If they fail, you'll need to use the Hub approach.${NC}"
npx eas-cli@latest init
if [ $? -ne 0 ]; then
  echo -e "  ❌ ${RED}Failed to initialize EAS project${NC}"
  echo -e "  ${YELLOW}This confirms our previous findings that the CLI approach may not work in all environments.${NC}"
  echo -e "  ${YELLOW}Please try the Hub approach instead using the transition-to-hub.sh script.${NC}"
  exit 1
else
  echo -e "  ✅ ${GREEN}Successfully initialized EAS project${NC}"
fi
echo ""

# Step 4: Configure build
echo -e "${YELLOW}Step 4: Configuring EAS build...${NC}"
echo -e "  ${BLUE}Executing: npx eas-cli@latest build:configure${NC}"
npx eas-cli@latest build:configure
if [ $? -ne 0 ]; then
  echo -e "  ❌ ${RED}Failed to configure EAS build${NC}"
  exit 1
else
  echo -e "  ✅ ${GREEN}Successfully configured EAS build${NC}"
fi
echo ""

# Step 5: Attempt a build
echo -e "${YELLOW}Step 5: Attempting an EAS build...${NC}"
echo -e "  ${BLUE}Executing: npx eas-cli@latest build --platform ios --profile development${NC}"
npx eas-cli@latest build --platform ios --profile development
if [ $? -ne 0 ]; then
  echo -e "  ❌ ${RED}Build process encountered issues${NC}"
  echo -e "  ${YELLOW}This may be expected based on our previous research.${NC}"
else
  echo -e "  ✅ ${GREEN}Build process started successfully${NC}"
fi
echo ""

# Final summary
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}           Summary           ${NC}"
echo -e "${BLUE}====================================${NC}"
echo -e "If all steps completed successfully, the CLI approach worked this time!"
echo -e "If any steps failed, this confirms our previous findings about limitations"
echo -e "with the CLI approach in certain environments or with historical accounts."
echo -e ""
echo -e "Please document your results in the EAS-SESSION-LOG.md file to continue"
echo -e "building our research on deployment methodologies."