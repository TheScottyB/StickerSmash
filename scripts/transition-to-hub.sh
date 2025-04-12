#!/bin/bash
# Script to help transition from EAS CLI to EAS Hub approach

# Define text colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Display header
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  EAS CLI to Hub Transition Helper  ${NC}"
echo -e "${BLUE}====================================${NC}"
echo ""

# Step 1: Check if all required configuration files exist
echo -e "${YELLOW}Step 1: Checking configuration files...${NC}"

config_files=(
  "../app.json"
  "../eas.json"
  "eas.json"
  "eas-workflows.yml"
)

all_files_exist=true
for file in "${config_files[@]}"; do
  if [ -f "$file" ]; then
    echo -e "  ✅ ${GREEN}$file exists${NC}"
  else
    echo -e "  ❌ ${RED}$file not found${NC}"
    all_files_exist=false
  fi
done

if [ "$all_files_exist" = false ]; then
  echo -e "${RED}Some required files are missing. Please create them before proceeding.${NC}"
else
  echo -e "${GREEN}All required configuration files exist.${NC}"
fi
echo ""

# Step 2: Check for Expo CLI installation
echo -e "${YELLOW}Step 2: Checking for Expo CLI installation...${NC}"
if command -v expo &> /dev/null; then
  expo_version=$(expo --version)
  echo -e "  ✅ ${GREEN}Expo CLI is installed (version: $expo_version)${NC}"
else
  echo -e "  ❌ ${RED}Expo CLI not found. Installing...${NC}"
  npm install -g expo-cli
fi

if command -v eas &> /dev/null; then
  eas_version=$(eas --version)
  echo -e "  ✅ ${GREEN}EAS CLI is installed (version: $eas_version)${NC}"
else
  echo -e "  ❌ ${RED}EAS CLI not found. Installing...${NC}"
  npm install -g eas-cli
fi
echo ""

# Step 3: Check Expo login status
echo -e "${YELLOW}Step 3: Checking Expo login status...${NC}"
expo_whoami_output=$(expo whoami 2>&1)
if [[ $expo_whoami_output == *"not logged in"* ]]; then
  echo -e "  ❌ ${RED}Not logged in to Expo. Please log in:${NC}"
  echo -e "  ${BLUE}expo login${NC}"
else
  echo -e "  ✅ ${GREEN}Logged in as: $expo_whoami_output${NC}"
fi
echo ""

# Step 4: Compare project IDs
echo -e "${YELLOW}Step 4: Checking project IDs...${NC}"
app_json_project_id=$(grep -o '"projectId": "[^"]*"' ../app.json | cut -d'"' -f4)
if [ -z "$app_json_project_id" ]; then
  echo -e "  ❓ ${YELLOW}No projectId found in app.json${NC}"
else
  echo -e "  ℹ️ ${BLUE}app.json projectId: $app_json_project_id${NC}"
  echo -e "  ${YELLOW}When connecting to the Hub, you'll need to replace this with the ID from the dashboard${NC}"
fi
echo ""

# Step 5: Check bundle identifier
echo -e "${YELLOW}Step 5: Checking bundle identifier...${NC}"
bundle_id=$(grep -o '"bundleIdentifier": "[^"]*"' ../app.json | cut -d'"' -f4)
if [ -z "$bundle_id" ]; then
  echo -e "  ❌ ${RED}No bundleIdentifier found in app.json${NC}"
else
  echo -e "  ✅ ${GREEN}Bundle identifier: $bundle_id${NC}"
fi
echo ""

# Step 6: List documentation files for transition
echo -e "${YELLOW}Step 6: Documentation files for transition:${NC}"
docs_files=(
  "HUB-DEPLOYMENT-LOG.md"
  "HUB-APPROACH-GUIDE.md"
  "CLI-VS-HUB-COMPARISON.md"
)
for file in "${docs_files[@]}"; do
  if [ -f "$file" ]; then
    echo -e "  ✅ ${GREEN}$file - Documentation available${NC}"
  else
    echo -e "  ❌ ${RED}$file not found${NC}"
  fi
done
echo ""

# Final instructions
echo -e "${BLUE}====================================${NC}"
echo -e "${BLUE}  Next Steps  ${NC}"
echo -e "${BLUE}====================================${NC}"
echo -e "1. Review the ${GREEN}HUB-APPROACH-GUIDE.md${NC} for detailed instructions"
echo -e "2. ${RED}CRITICAL STEP:${NC} Go to ${GREEN}https://expo.dev${NC} and:"
echo -e "   a. Create a new project or select existing one"
echo -e "   b. ${RED}Manually connect your GitHub repository${NC} (EAS Workflows won't work without this!)"
echo -e "   c. Install the Expo GitHub app when prompted"
echo -e "3. Update projectId in app.json with the one from the dashboard"
echo -e "4. Push the ${GREEN}eas-workflows.yml${NC} file to your repository"
echo -e "5. Document your experience in ${GREEN}HUB-DEPLOYMENT-LOG.md${NC}"
echo ""
echo -e "${RED}IMPORTANT:${NC} The GitHub repository connection cannot be automated and must be done"
echo -e "manually through the Expo web dashboard. This is a prerequisite for EAS Workflows."
echo ""
echo -e "${YELLOW}Happy deploying!${NC}"