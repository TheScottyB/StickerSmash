#!/bin/bash
# Script to trigger automated deployment workflow

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Move to the project root directory where package.json is located
cd ..

# Display deployment options
echo -e "${YELLOW}=== Automated iOS Deployment Options ===${NC}"
echo -e "1) Start development build (simulator)"
echo -e "2) Start production build and App Store submission (cloud)"
echo -e "3) Start production build and App Store submission (local)"
echo -e "4) Trigger via Git tag (fully automated)"
echo -e "\nSelect an option (1-4):"
read -r OPTION

case $OPTION in
  1)
    echo -e "${YELLOW}Starting development build for iOS simulator...${NC}"
    npx eas-cli build --platform ios --profile development --non-interactive
    ;;
  2)
    echo -e "${YELLOW}Starting production build and App Store submission (cloud)...${NC}"
    echo -e "${YELLOW}This will trigger a build with the production profile and submit to the App Store.${NC}"
    echo -e "${YELLOW}Continue? (y/n)${NC}"
    read -r CONFIRM
    if [[ $CONFIRM == "y" ]]; then
      # Check if workflow is enabled
      if grep -q "\"workflows\": true" ./eas.json; then
        echo -e "${GREEN}Using EAS Workflows for the build process...${NC}"
        npx eas-cli workflow:run production-release
      else
        echo -e "${YELLOW}Using standard EAS build and submit process...${NC}"
        BUILD_ID=$(npx eas-cli build --platform ios --profile production --non-interactive --json | jq -r '.id')
        if [ -n "$BUILD_ID" ] && [ "$BUILD_ID" != "null" ]; then
          echo -e "${GREEN}Build ID: $BUILD_ID${NC}"
          echo -e "${YELLOW}Submitting build to App Store...${NC}"
          npx eas-cli submit --platform ios --id "$BUILD_ID" --non-interactive
        else
          echo -e "${RED}Failed to get build ID. Submission aborted.${NC}"
        fi
      fi
    else
      echo -e "${YELLOW}Production build and submission cancelled.${NC}"
    fi
    ;;
  3)
    echo -e "${YELLOW}Starting production build and App Store submission (local)...${NC}"
    echo -e "${YELLOW}This will build the app locally and submit it to the App Store.${NC}"
    echo -e "${YELLOW}Continue? (y/n)${NC}"
    read -r CONFIRM
    if [[ $CONFIRM == "y" ]]; then
      echo -e "${YELLOW}Building locally...${NC}"
      npx eas-cli build --platform ios --profile production --local --output=./build.ipa
      
      if [ -f "./build.ipa" ]; then
        echo -e "${GREEN}Local build successful. IPA file created.${NC}"
        echo -e "${YELLOW}Submitting to App Store...${NC}"
        npx eas-cli submit --platform ios --path ./build.ipa --non-interactive
      else
        echo -e "${RED}Local build failed or IPA file not found. Submission aborted.${NC}"
      fi
    else
      echo -e "${YELLOW}Local production build and submission cancelled.${NC}"
    fi
    ;;
  4)
    echo -e "${YELLOW}Creating and pushing Git tag to trigger automated workflow...${NC}"
    echo -e "${YELLOW}Enter version number (e.g., 1.0.0):${NC}"
    read -r VERSION
    
    # Determine current branch
    CURRENT_BRANCH=$(git branch --show-current)
    
    echo -e "${YELLOW}Creating tag prod-ios-v$VERSION on branch $CURRENT_BRANCH...${NC}"
    git tag "prod-ios-v$VERSION"
    
    echo -e "${YELLOW}Pushing tag to remote repository...${NC}"
    git push origin "prod-ios-v$VERSION"
    
    echo -e "${GREEN}Successfully pushed tag prod-ios-v$VERSION${NC}"
    echo -e "${YELLOW}The EAS workflow will automatically detect this tag and start the build+submit process${NC}"
    echo -e "${YELLOW}You can monitor the build status on the EAS Dashboard${NC}"
    ;;
  *)
    echo -e "${RED}Invalid option selected${NC}"
    exit 1
    ;;
esac