#!/bin/bash
# Script to fix nested directory structure and duplicate configuration files

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PROJECT_ROOT=$(pwd)
echo -e "${YELLOW}Project root: ${PROJECT_ROOT}${NC}"

# Check if we have duplicate eas.json files
NUM_EAS_FILES=$(find "${PROJECT_ROOT}" -name "eas.json" | wc -l)
echo -e "Found ${NUM_EAS_FILES} eas.json files"

# Check if we have app.json in multiple locations
APP_JSON_FILES=$(find "${PROJECT_ROOT}" -name "app.json")
echo -e "Found app.json at:"
echo "${APP_JSON_FILES}"

echo -e "${YELLOW}This script will fix your project structure by:${NC}"
echo -e "1. Moving all configuration files to the project root"
echo -e "2. Removing duplicate configuration files"
echo -e "3. Making your project structure compatible with Expo builds"

echo -e "${YELLOW}Proceed? (y/n)${NC}"
read -r PROCEED

if [[ $PROCEED != "y" ]]; then
    echo -e "${RED}Aborted.${NC}"
    exit 1
fi

# First, back up everything
BACKUP_DIR="${PROJECT_ROOT}/config_backup_$(date +%s)"
mkdir -p "${BACKUP_DIR}"
echo -e "${YELLOW}Creating backup in ${BACKUP_DIR}${NC}"

# Backup eas.json files
find "${PROJECT_ROOT}" -name "eas.json" -exec cp --parents {} "${BACKUP_DIR}" \;
# Backup app.json files
find "${PROJECT_ROOT}" -name "app.json" -exec cp --parents {} "${BACKUP_DIR}" \;
# Backup store.config.json files
find "${PROJECT_ROOT}" -name "store.config.json" -exec cp --parents {} "${BACKUP_DIR}" \;

echo -e "${GREEN}Backup complete${NC}"

# Find the primary app.json (prefer the root one if it exists)
if [[ -f "${PROJECT_ROOT}/app.json" ]]; then
    PRIMARY_APP_JSON="${PROJECT_ROOT}/app.json"
elif [[ -f "${PROJECT_ROOT}/app/app.json" ]]; then
    PRIMARY_APP_JSON="${PROJECT_ROOT}/app/app.json"
else
    # Use the first one found
    PRIMARY_APP_JSON=$(find "${PROJECT_ROOT}" -name "app.json" | head -n 1)
fi

echo -e "${YELLOW}Using primary app.json: ${PRIMARY_APP_JSON}${NC}"

# Copy the primary app.json to the root if needed
if [[ "${PRIMARY_APP_JSON}" != "${PROJECT_ROOT}/app.json" ]]; then
    echo -e "${YELLOW}Copying ${PRIMARY_APP_JSON} to ${PROJECT_ROOT}/app.json${NC}"
    cp "${PRIMARY_APP_JSON}" "${PROJECT_ROOT}/app.json"
fi

# Find the primary eas.json
if [[ -f "${PROJECT_ROOT}/eas.json" ]]; then
    PRIMARY_EAS_JSON="${PROJECT_ROOT}/eas.json"
elif [[ -f "${PROJECT_ROOT}/app/eas.json" ]]; then
    PRIMARY_EAS_JSON="${PROJECT_ROOT}/app/eas.json"
else
    # Use the first one found
    PRIMARY_EAS_JSON=$(find "${PROJECT_ROOT}" -name "eas.json" | head -n 1)
fi

echo -e "${YELLOW}Using primary eas.json: ${PRIMARY_EAS_JSON}${NC}"

# Copy the primary eas.json to the root if needed
if [[ "${PRIMARY_EAS_JSON}" != "${PROJECT_ROOT}/eas.json" ]]; then
    echo -e "${YELLOW}Copying ${PRIMARY_EAS_JSON} to ${PROJECT_ROOT}/eas.json${NC}"
    cp "${PRIMARY_EAS_JSON}" "${PROJECT_ROOT}/eas.json"
fi

# Find store.config.json
STORE_CONFIG=$(find "${PROJECT_ROOT}" -name "store.config.json" | head -n 1)
if [[ -n "${STORE_CONFIG}" ]]; then
    echo -e "${YELLOW}Found store.config.json at ${STORE_CONFIG}${NC}"
    # Copy it to the root if it's not already there
    if [[ "${STORE_CONFIG}" != "${PROJECT_ROOT}/store.config.json" ]]; then
        echo -e "${YELLOW}Copying ${STORE_CONFIG} to ${PROJECT_ROOT}/store.config.json${NC}"
        cp "${STORE_CONFIG}" "${PROJECT_ROOT}/store.config.json"
    fi
fi

# Now let's clean up the nested app/app directory if it exists
if [[ -d "${PROJECT_ROOT}/app/app" ]]; then
    echo -e "${YELLOW}Found nested app/app directory. Do you want to remove it? (y/n)${NC}"
    read -r REMOVE_NESTED
    
    if [[ $REMOVE_NESTED == "y" ]]; then
        echo -e "${YELLOW}Moving files from app/app to app directory...${NC}"
        # Move any files from app/app to app
        cp -r "${PROJECT_ROOT}/app/app/"* "${PROJECT_ROOT}/app/" 2>/dev/null || true
        echo -e "${YELLOW}Removing app/app directory...${NC}"
        rm -rf "${PROJECT_ROOT}/app/app"
        echo -e "${GREEN}Nested app/app directory removed.${NC}"
    fi
fi

echo -e "${GREEN}Directory structure has been fixed!${NC}"
echo -e "${YELLOW}Key configuration files are now at:${NC}"
echo -e "- app.json: ${PROJECT_ROOT}/app.json"
echo -e "- eas.json: ${PROJECT_ROOT}/eas.json"
if [[ -f "${PROJECT_ROOT}/store.config.json" ]]; then
    echo -e "- store.config.json: ${PROJECT_ROOT}/store.config.json"
fi

echo -e "${YELLOW}Note: A backup of all configuration files has been saved to ${BACKUP_DIR}${NC}"
echo -e "${YELLOW}You may want to commit these changes to git before proceeding with builds.${NC}"

exit 0