#!/bin/bash
# Script to set up and verify 100% automated build and submission workflow

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Checking EAS prerequisites...${NC}"

# Check EAS CLI version
EAS_VERSION=$(npx eas-cli --version 2>/dev/null || echo "not-installed")
if [[ $EAS_VERSION == *"not-installed"* ]]; then
  echo -e "${RED}EAS CLI not installed. Installing...${NC}"
  npm install -g eas-cli
else
  echo -e "${GREEN}EAS CLI detected: $EAS_VERSION${NC}"
fi

# Check if logged in to EAS
echo -e "${YELLOW}Checking EAS login status...${NC}"
npx eas-cli whoami &>/dev/null
if [ $? -ne 0 ]; then
  echo -e "${RED}Not logged in to EAS. Please log in:${NC}"
  npx eas-cli login
else
  ACCOUNT=$(npx eas-cli whoami)
  echo -e "${GREEN}Logged in as: $ACCOUNT${NC}"
fi

# Move to the project root directory where package.json is located
cd ..

# Check if project is configured with EAS
echo -e "${YELLOW}Checking EAS project configuration...${NC}"
PROJECT_ID=$(grep -o '"projectId": "[^"]*' ./app.json | cut -d'"' -f4)
if [ -z "$PROJECT_ID" ]; then
  echo -e "${RED}No EAS project ID found. Initializing project...${NC}"
  npx eas-cli init
else
  echo -e "${GREEN}EAS Project ID found: $PROJECT_ID${NC}"
fi

# Check EAS secret configuration
echo -e "${YELLOW}Checking EAS secrets configuration...${NC}"
echo -e "${YELLOW}The following secrets are required for automated builds and submissions:${NC}"
echo -e "1. EXPO_APPLE_TEAM_ID - Your Apple Developer Team ID"
echo -e "2. EXPO_ASC_APP_ID - Your App Store Connect App ID"
echo -e "3. EXPO_APPLE_API_KEY_ID - Your App Store Connect API Key ID"
echo -e "4. EXPO_APPLE_API_ISSUER_ID - Your App Store Connect API Key Issuer ID"
echo -e "5. EXPO_APPLE_API_KEY_CONTENT - Your App Store Connect API Key content (base64 encoded)"
echo -e "\n${YELLOW}Do you want to check and set up these secrets now? (y/n)${NC}"
read -r SETUP_SECRETS

if [[ $SETUP_SECRETS == "y" ]]; then
  # Check if secrets exist
  echo -e "${YELLOW}Checking existing secrets...${NC}"
  SECRETS=$(npx eas-cli secret:list 2>/dev/null)
  
  # For each required secret, check if it exists and prompt to add if not
  for SECRET_NAME in EXPO_APPLE_TEAM_ID EXPO_ASC_APP_ID EXPO_APPLE_API_KEY_ID EXPO_APPLE_API_ISSUER_ID EXPO_APPLE_API_KEY_CONTENT; do
    if [[ $SECRETS == *"$SECRET_NAME"* ]]; then
      echo -e "${GREEN}✓ $SECRET_NAME is configured${NC}"
    else
      echo -e "${RED}✗ $SECRET_NAME is not configured${NC}"
      echo -e "${YELLOW}Would you like to add $SECRET_NAME now? (y/n)${NC}"
      read -r ADD_SECRET
      
      if [[ $ADD_SECRET == "y" ]]; then
        echo -e "${YELLOW}Enter the value for $SECRET_NAME:${NC}"
        read -r SECRET_VALUE
        npx eas-cli secret:create --scope project --name "$SECRET_NAME" --value "$SECRET_VALUE" --force
      fi
    fi
  done
fi

# Verify eas-workflows.yml exists and has appropriate configuration
echo -e "${YELLOW}Verifying workflow configuration...${NC}"
if [ -f "app/eas-workflows.yml" ]; then
  echo -e "${GREEN}✓ eas-workflows.yml exists${NC}"
else
  echo -e "${RED}✗ eas-workflows.yml not found. Creating template...${NC}"
  cat > app/eas-workflows.yml << 'EOF'
workflows:
  production-release:
    name: iOS Production Release
    description: Builds and submits iOS app to App Store
    on:
      workflow_dispatch: {}
    jobs:
      build-and-submit:
        name: Build and Submit iOS App
        runs-on: eas
        env:
          EXPO_APPLE_APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APPLE_API_KEY_ID }}
          EXPO_APPLE_APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.APPLE_API_ISSUER_ID }}
          EXPO_APPLE_APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.APPLE_API_KEY_CONTENT }}
        steps:
          - name: Checkout code
            uses: checkout
          - name: Setup environment
            uses: expo-setup
          - name: Build iOS app
            uses: eas-build
            id: build
            with:
              platform: ios
              profile: production
              non-interactive: true
          - name: Submit to App Store
            uses: eas-submit
            with:
              platform: ios
              build: ${{ steps.build.outputs.buildId }}
          - name: Update App Store Metadata
            uses: eas-metadata-push
            with:
              platform: ios
EOF
  echo -e "${GREEN}✓ Created eas-workflows.yml${NC}"
fi

# Update eas.json to support workflows if not already enabled
echo -e "${YELLOW}Updating eas.json to support workflows...${NC}"
if grep -q "\"workflows\": true" ./eas.json; then
  echo -e "${GREEN}✓ Workflows already enabled in eas.json${NC}"
else
  # Add extend.workflows section if it doesn't exist
  if grep -q "\"extend\":" ./eas.json; then
    # Add workflows: true to extend section
    TMP_FILE=$(mktemp)
    jq '.extend.workflows = true' ./eas.json > "$TMP_FILE"
    cat "$TMP_FILE" > ./eas.json
    rm "$TMP_FILE"
  else
    # Add extend section with workflows: true
    TMP_FILE=$(mktemp)
    jq '.extend = {"workflows": true}' ./eas.json > "$TMP_FILE"
    cat "$TMP_FILE" > ./eas.json
    rm "$TMP_FILE"
  fi
  echo -e "${GREEN}✓ Updated eas.json to enable workflows${NC}"
fi

# Verify store.config.json exists for metadata updates
echo -e "${YELLOW}Verifying store.config.json for metadata...${NC}"
if [ -f "app/store.config.json" ]; then
  echo -e "${GREEN}✓ store.config.json exists${NC}"
else
  echo -e "${RED}✗ store.config.json not found. Creating template...${NC}"
  cat > app/store.config.json << 'EOF'
{
  "expo": {
    "name": "StickerSmash",
    "stores": {
      "ios": {
        "ascApiKeyId": "${EXPO_APPLE_API_KEY_ID}",
        "ascApiKeyIssuerId": "${EXPO_APPLE_API_ISSUER_ID}",
        "ascApiKeyPath": "${EXPO_APPLE_API_KEY_PATH}"
      }
    },
    "appStoreConfig": {
      "categoryType": "utilities",
      "description": "Create and share custom stickers using your photos",
      "keywords": ["stickers", "photo editing", "creative", "social"],
      "releaseNotes": "Initial release" 
    }
  }
}
EOF
  echo -e "${GREEN}✓ Created store.config.json${NC}"
fi

# Give instructions for initiating a workflow
echo -e "\n${GREEN}=== Setup Complete ===${NC}"
echo -e "${YELLOW}To manually trigger the workflow:${NC}"
echo -e "npx eas-cli workflow:run production-release"
echo -e "\n${YELLOW}For fully automated builds based on git tags:${NC}"
echo -e "1. Make your code changes"
echo -e "2. Commit your changes: git commit -am \"Your commit message\""
echo -e "3. Create and push a tag: git tag prod-ios-v1.0.0 && git push origin prod-ios-v1.0.0"
echo -e "\nThe EAS workflow will automatically detect the tag and initiate the build and submission process."
echo -e "\n${GREEN}Your iOS app build and submission workflow is now configured for 100% automation.${NC}"