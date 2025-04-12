#!/bin/bash
# Direct script for local builds without GraphQL dependency

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
    
    # Get the bundle identifier from app.json
    BUNDLE_ID=$(jq -r '.expo.ios.bundleIdentifier' app.json)
    APP_NAME=$(jq -r '.expo.name' app.json)
    
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
            npx eas-cli submit --platform ios --path "${BUILD_DIR}/${APP_NAME}.ipa" --non-interactive
        else
            echo -e "${YELLOW}Skipping submission. You can manually submit later with:${NC}"
            echo -e "npx eas-cli submit --platform ios --path \"${BUILD_DIR}/${APP_NAME}.ipa\" --non-interactive"
        fi
    else
        echo -e "${RED}Failed to create IPA file.${NC}"
    fi
else
    echo -e "${RED}Invalid option selected${NC}"
    exit 1
fi