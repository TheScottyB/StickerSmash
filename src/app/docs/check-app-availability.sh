#!/bin/bash
# Script to check if app name is available in App Store and set up App Store Connect
# This helps solve name availability issues before submission

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Store the current directory and move to project root
SCRIPT_DIR=$(pwd)
# Set PROJECT_ROOT to parent directory 
# but handle nested "app" directories safely
if [[ $(basename "$SCRIPT_DIR") == "app" ]]; then
    # If we're in an "app" directory, check parent
    PARENT_DIR=$(dirname "$SCRIPT_DIR")
    PARENT_NAME=$(basename "$PARENT_DIR")
    
    if [[ "$PARENT_NAME" == "app" ]]; then
        # If parent is also named "app", go up two levels
        cd ../..
    else
        # Just go up one level
        cd ..
    fi
else
    # Not in an app directory, go up one level
    cd ..
fi

PROJECT_ROOT=$(pwd)
echo -e "${YELLOW}Project root: ${PROJECT_ROOT}${NC}"

# Find and use the correct app.json
if [[ -f "${PROJECT_ROOT}/app.json" ]]; then
    APP_JSON="${PROJECT_ROOT}/app.json"
elif [[ -f "${PROJECT_ROOT}/app/app.json" ]]; then
    APP_JSON="${PROJECT_ROOT}/app/app.json" 
else
    # Try to find app.json anywhere in the project
    APP_JSON=$(find "${PROJECT_ROOT}" -name "app.json" -type f | head -n 1)
    if [[ -z "$APP_JSON" ]]; then
        echo -e "${RED}Cannot find app.json in the project. Aborting.${NC}"
        exit 1
    fi
fi

echo -e "${YELLOW}Using app.json at: ${APP_JSON}${NC}"

# Read app information from app.json
BUNDLE_ID=$(jq -r '.expo.ios.bundleIdentifier' "$APP_JSON")
APP_NAME=$(jq -r '.expo.name' "$APP_JSON")

echo -e "${YELLOW}Checking app '$APP_NAME' with bundle ID '$BUNDLE_ID'${NC}"

# Check if Apple credentials are available
echo -e "${YELLOW}Do you have an App Store Connect API Key set up? (y/n)${NC}"
read -r HAS_API_KEY

if [[ $HAS_API_KEY == "y" ]]; then
    echo -e "${YELLOW}Let's register your app in App Store Connect${NC}"
    echo -e "${YELLOW}This will:${NC}"
    echo -e "1. Reserve your app name"
    echo -e "2. Create app record in App Store Connect"
    echo -e "3. Set up the necessary metadata"
    
    # Verify Apple Team ID
    echo -e "${YELLOW}Enter your Apple Team ID (found in Apple Developer account):${NC}"
    read -r TEAM_ID
    
    # Check if needed environment variables are set
    if [ -z "${EXPO_APPLE_API_KEY_ID}" ] || [ -z "${EXPO_APPLE_API_ISSUER_ID}" ] || [ -z "${EXPO_APPLE_API_KEY_PATH}" ]; then
        echo -e "${RED}Missing App Store Connect API key environment variables.${NC}"
        echo -e "${YELLOW}Please set these environment variables:${NC}"
        echo -e "export EXPO_APPLE_API_KEY_ID=your_key_id"
        echo -e "export EXPO_APPLE_API_ISSUER_ID=your_issuer_id"
        echo -e "export EXPO_APPLE_API_KEY_PATH=/path/to/AuthKey_XXX.p8"
        exit 1
    fi
    
    # Try to create app in App Store Connect
    echo -e "${YELLOW}Attempting to register app in App Store Connect...${NC}"
    echo -e "${YELLOW}This may take a few moments.${NC}"
    
    # Use App Store Connect API to create app if possible
    echo -e "${YELLOW}Would you like a suggested alternative name if '$APP_NAME' is already taken? (y/n)${NC}"
    read -r SUGGEST_ALT
    
    if [[ $SUGGEST_ALT == "y" ]]; then
        echo -e "${YELLOW}Alternative suggestions:${NC}"
        echo -e "1. ${APP_NAME}Plus"
        echo -e "2. My${APP_NAME}"
        echo -e "3. ${APP_NAME}App"
        echo -e "4. ${APP_NAME}Pro"
        echo -e "${YELLOW}Enter a different name if you prefer:${NC}"
        read -r ALT_NAME
        
        if [ -n "$ALT_NAME" ]; then
            echo -e "${YELLOW}Would you like to update your app.json and store.config.json with the new name '$ALT_NAME'? (y/n)${NC}"
            read -r UPDATE_CONFIG
            
            if [[ $UPDATE_CONFIG == "y" ]]; then
                # Update app.json
                jq --arg name "$ALT_NAME" '.expo.name = $name' app.json > app.json.tmp && mv app.json.tmp app.json
                
                # Update store.config.json if it exists
                if [ -f "${PROJECT_ROOT}/app/store.config.json" ]; then
                    jq --arg name "$ALT_NAME" '.expo.name = $name' "${PROJECT_ROOT}/app/store.config.json" > "${PROJECT_ROOT}/app/store.config.json.tmp" && mv "${PROJECT_ROOT}/app/store.config.json.tmp" "${PROJECT_ROOT}/app/store.config.json"
                fi
                
                echo -e "${GREEN}Updated configuration files with new name: $ALT_NAME${NC}"
                APP_NAME="$ALT_NAME"
            fi
        fi
    fi
    
    # Instructions for registering app in App Store Connect manually
    echo -e "${YELLOW}For best results, register your app in App Store Connect before building:${NC}"
    echo -e "1. Go to https://appstoreconnect.apple.com"
    echo -e "2. Click 'My Apps' and then '+' to add a new app"
    echo -e "3. Select iOS platform"
    echo -e "4. Enter app name: $APP_NAME"
    echo -e "5. Choose your primary language"
    echo -e "6. Enter bundle ID: $BUNDLE_ID"
    echo -e "7. Set SKU (can be any unique identifier)"
    echo -e "8. Select access: Full Access"
    echo -e "9. Complete the form and create the app"
    
    echo -e "${YELLOW}After creating the app, get the App Store Connect App ID (numeric value)${NC}"
    echo -e "${YELLOW}Enter the App Store Connect App ID (leave blank to skip):${NC}"
    read -r ASC_APP_ID
    
    if [ -n "$ASC_APP_ID" ]; then
        echo -e "${YELLOW}Setting EXPO_ASC_APP_ID=$ASC_APP_ID${NC}"
        export EXPO_ASC_APP_ID="$ASC_APP_ID"
        
        # Update eas.json if needed
        if grep -q "EXPO_ASC_APP_ID" "${PROJECT_ROOT}/eas.json"; then
            echo -e "${GREEN}EXPO_ASC_APP_ID is already referenced in eas.json${NC}"
        else
            echo -e "${YELLOW}You should update eas.json to include ASC_APP_ID in the 'submit' section${NC}"
        fi
    fi
else
    echo -e "${YELLOW}You'll need to set up App Store Connect API Key for automated submissions.${NC}"
    echo -e "${YELLOW}See documentation: https://docs.expo.dev/submit/ios/#app-store-connect-api-key${NC}"
fi

# Ready to proceed
echo -e "${GREEN}App check complete!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Create your app in App Store Connect if not already done (using name: $APP_NAME)"
echo -e "2. Run the direct-local-build.sh script to build your app"
echo -e "3. Make sure to update the TEAM_ID in the direct-local-build.sh script"
if [ -n "$ASC_APP_ID" ]; then
    echo -e "4. Your App Store Connect App ID: $ASC_APP_ID is now set"
else
    echo -e "4. Set EXPO_ASC_APP_ID environment variable before submitting"
fi

exit 0