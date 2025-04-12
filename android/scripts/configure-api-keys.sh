#!/bin/bash
# Script to help configure Apple App Store Connect API keys

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}This script will help you configure App Store Connect API keys${NC}"
echo -e "${YELLOW}You'll need these for automated build submission to the App Store${NC}"

echo -e "${YELLOW}Do you have an App Store Connect API Key? (y/n)${NC}"
read -r HAS_KEY

if [[ $HAS_KEY != "y" ]]; then
    echo -e "${YELLOW}Let's create one. Follow these steps:${NC}"
    echo -e "1. Go to https://appstoreconnect.apple.com/access/api"
    echo -e "2. Click the '+' button to create a new key"
    echo -e "3. Give it a name like 'Expo Build Key'"
    echo -e "4. Select 'Admin' access (required for submissions)"
    echo -e "5. Download the .p8 key file when prompted"
    echo -e "6. Note the Key ID and Issuer ID shown on the screen"
    echo -e "${YELLOW}Once you have created the key, press any key to continue${NC}"
    read -n 1 -s
fi

# Get the key information
echo -e "${YELLOW}Enter your API Key ID:${NC}"
read -r KEY_ID

echo -e "${YELLOW}Enter your API Issuer ID:${NC}"
read -r ISSUER_ID

echo -e "${YELLOW}Enter the path to your .p8 key file:${NC}"
read -r KEY_PATH

# Verify the key file exists
if [[ ! -f "$KEY_PATH" ]]; then
    echo -e "${RED}Error: Key file not found at $KEY_PATH${NC}"
    exit 1
fi

# Create a secure location for the key
SECURE_DIR="/Users/scottybe/Workspace/expo-ios/StickerSmash/secure_configs"
mkdir -p "$SECURE_DIR"

# Copy the key to secure location
KEY_FILENAME=$(basename "$KEY_PATH")
cp "$KEY_PATH" "$SECURE_DIR/$KEY_FILENAME"

echo -e "${GREEN}Key file copied to $SECURE_DIR/$KEY_FILENAME${NC}"

# Generate commands to set environment variables
echo -e "${YELLOW}Add these lines to your shell profile (.zshrc, .bash_profile, etc.):${NC}"
echo ""
echo "export EXPO_APPLE_API_KEY_ID=\"$KEY_ID\""
echo "export EXPO_APPLE_API_ISSUER_ID=\"$ISSUER_ID\""
echo "export EXPO_APPLE_API_KEY_PATH=\"$SECURE_DIR/$KEY_FILENAME\""
echo ""

# Get Apple Team ID
echo -e "${YELLOW}Enter your Apple Team ID (from Apple Developer Portal):${NC}"
read -r TEAM_ID

echo -e "${YELLOW}Enter your App Store Connect App ID (numeric value):${NC}"
read -r ASC_APP_ID

echo "export EXPO_APPLE_TEAM_ID=\"$TEAM_ID\""
echo "export EXPO_ASC_APP_ID=\"$ASC_APP_ID\""
echo ""

# Set them for current session
export EXPO_APPLE_API_KEY_ID="$KEY_ID"
export EXPO_APPLE_API_ISSUER_ID="$ISSUER_ID"
export EXPO_APPLE_API_KEY_PATH="$SECURE_DIR/$KEY_FILENAME"
export EXPO_APPLE_TEAM_ID="$TEAM_ID"
export EXPO_ASC_APP_ID="$ASC_APP_ID"

# Update the direct-local-build.sh script with the team ID
if [[ -f "/Users/scottybe/Workspace/expo-ios/StickerSmash/app/scripts/direct-local-build.sh" ]]; then
    sed -i '' "s/TEAM_ID=\"YOUR_APPLE_TEAM_ID\"/TEAM_ID=\"$TEAM_ID\"/" "/Users/scottybe/Workspace/expo-ios/StickerSmash/app/scripts/direct-local-build.sh"
    echo -e "${GREEN}Updated direct-local-build.sh with your Team ID${NC}"
fi

echo -e "${GREEN}Environment variables set for current session.${NC}"
echo -e "${YELLOW}You can now run the direct-local-build.sh script to build and submit your app${NC}"

# Create a quick run command for reference
echo -e "${YELLOW}Quick run commands (copy and paste these):${NC}"
echo "cd /Users/scottybe/Workspace/expo-ios/StickerSmash/app/scripts"
echo "./direct-local-build.sh"

exit 0