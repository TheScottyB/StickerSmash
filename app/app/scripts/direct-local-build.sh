#!/bin/bash
# Direct script for local builds without GraphQL dependency

# Set your Apple Team ID here (required for signing)
TEAM_ID="YOUR_APPLE_TEAM_ID"  # Replace with your actual Team ID

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

# Create build directory
BUILD_DIR="${PROJECT_ROOT}/builds"
mkdir -p "${BUILD_DIR}"

# Run build directly with expo CLI
echo -e "${YELLOW}Starting direct local build with Expo CLI${NC}"
echo -e "${YELLOW}This bypasses EAS API and builds directly on this machine${NC}"

# Ensure Xcode tools are available
if ! command -v xcodebuild &> /dev/null; then
    echo -e "${RED}Xcode command line tools not found. Please install Xcode.${NC}"
    exit 1
fi

# Choose whether to build for simulator or device
echo -e "${YELLOW}Choose build type:${NC}"
echo -e "1) Simulator build (faster, for testing)"
echo -e "2) Device build (for App Store submission)"
read -r BUILD_TYPE

# Ensure environment is set up
cd "${PROJECT_ROOT}"

if [[ $BUILD_TYPE == "1" ]]; then
    echo -e "${YELLOW}Building for iOS simulator...${NC}"
    npx expo run:ios --no-dev --no-minify
elif [[ $BUILD_TYPE == "2" ]]; then
    echo -e "${YELLOW}Building for iOS device (archive)...${NC}"
    
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
    
    # Get the bundle identifier from app.json
    BUNDLE_ID=$(jq -r '.expo.ios.bundleIdentifier' "$APP_JSON")
    APP_NAME=$(jq -r '.expo.name' "$APP_JSON")
    
    # Verify app has been created in App Store Connect
    echo -e "${YELLOW}Checking if app exists in App Store Connect...${NC}"
    if [ -z "${EXPO_ASC_APP_ID}" ]; then
        echo -e "${RED}Warning: EXPO_ASC_APP_ID environment variable is not set.${NC}"
        echo -e "${YELLOW}You need to create the app in App Store Connect first and set the App ID.${NC}"
        echo -e "${YELLOW}Do you want to continue anyway? This may fail if the app doesn't exist. (y/n)${NC}"
        read -r CONTINUE
        if [[ $CONTINUE != "y" ]]; then
            echo -e "${YELLOW}Exiting. Please create the app in App Store Connect first.${NC}"
            exit 1
        fi
    fi
    
    # First, build the app
    echo -e "${YELLOW}Building with native tools. This may take several minutes...${NC}"
    npx expo prebuild --clean
    cd ios
    
    # Build archive
    echo -e "${YELLOW}Building archive with xcodebuild...${NC}"
    xcodebuild -workspace ${APP_NAME}.xcworkspace -scheme ${APP_NAME} -configuration Release -archivePath "${BUILD_DIR}/${APP_NAME}.xcarchive" archive
    
    # Create exportOptions.plist
    cat > "${BUILD_DIR}/exportOptions.plist" << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>${TEAM_ID}</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
EOL
    
    # Export IPA
    echo -e "${YELLOW}Exporting IPA...${NC}"
    xcodebuild -exportArchive -archivePath "${BUILD_DIR}/${APP_NAME}.xcarchive" -exportPath "${BUILD_DIR}" -exportOptionsPlist "${BUILD_DIR}/exportOptions.plist"
    
    if [ -f "${BUILD_DIR}/${APP_NAME}.ipa" ]; then
        echo -e "${GREEN}Successfully created IPA: ${BUILD_DIR}/${APP_NAME}.ipa${NC}"
        echo -e "${YELLOW}Would you like to submit this build to the App Store? (y/n)${NC}"
        read -r SUBMIT
        
        if [[ $SUBMIT == "y" ]]; then
            echo -e "${YELLOW}Submitting to App Store...${NC}"
            cd "${PROJECT_ROOT}"
            
            # Set ASC_APP_ID if it's not set but exists in environment
            if [ -n "${EXPO_ASC_APP_ID}" ]; then
                ASC_APP_ID_FLAG="--asc-app-id ${EXPO_ASC_APP_ID}"
            else
                ASC_APP_ID_FLAG=""
                echo -e "${YELLOW}Warning: EXPO_ASC_APP_ID not set. Submission may fail if app doesn't exist in App Store Connect.${NC}"
            fi
            
            # Run submission with verbose flag to see more details about potential errors
            echo -e "${YELLOW}Running submission with flags: --platform ios --path \"${BUILD_DIR}/${APP_NAME}.ipa\" ${ASC_APP_ID_FLAG} --verbose --non-interactive${NC}"
            npx eas-cli submit --platform ios --path "${BUILD_DIR}/${APP_NAME}.ipa" ${ASC_APP_ID_FLAG} --verbose --non-interactive
            
            # Check submission status
            if [ $? -ne 0 ]; then
                echo -e "${RED}Submission failed. This could be due to:${NC}"
                echo -e "${RED}1. App name 'MyStickersApp' may already be taken in the App Store${NC}"
                echo -e "${RED}2. The app may not exist in App Store Connect yet${NC}"
                echo -e "${RED}3. App Store Connect credentials or API keys may be incorrect${NC}"
                echo -e "${YELLOW}Consider:${NC}"
                echo -e "1. Checking App Store Connect to see if 'MyStickersApp' is available"
                echo -e "2. Creating the app in App Store Connect first if not already done"
                echo -e "3. Trying a different app name in app.json and store.config.json"
            fi
        else
            echo -e "${YELLOW}Skipping submission. You can manually submit later with:${NC}"
            echo -e "npx eas-cli submit --platform ios --path \"${BUILD_DIR}/${APP_NAME}.ipa\" --asc-app-id YOUR_ASC_APP_ID --non-interactive"
        fi
    else
        echo -e "${RED}Failed to create IPA file.${NC}"
    fi
else
    echo -e "${RED}Invalid option selected${NC}"
    exit 1
fi