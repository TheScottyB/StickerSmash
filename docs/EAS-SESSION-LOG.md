# EAS Deployment Session Log

Date: April 12, 2025

## Initial Setup

### 1. Attempting global installation of EAS CLI

```bash
npm install -g eas-cli
```

**Error encountered**: Permission denied error when trying to install globally.
```
npm error code EACCES
npm error syscall mkdir
npm error path /usr/local/lib/node_modules/eas-cli
npm error errno -13
npm error Error: EACCES: permission denied, mkdir '/usr/local/lib/node_modules/eas-cli'
```

### 2. Using local installation instead

```bash
npm install eas-cli --save-dev
```

**Result**: Successfully installed EAS CLI locally
```
added 244 packages, and audited 1374 packages in 5s
```

Some deprecated package warnings were shown, but installation was successful.

### 3. Logging in with locally installed EAS

```bash
npx eas login
```

**Result**: Already logged in as "djscottyb"
```
Error: account:login command failed.
You are already logged in as djscottyb.
```

This is good news - we're already authenticated with EAS.

### 4. Attempt to configure project for EAS builds

```bash
npx eas build:configure
```

**Error encountered**: Invalid UUID appId
```
Error: GraphQL request failed.
Invalid UUID appId
```

### 5. Update configuration files

Modified `app.json`:
- Changed slug to "sticker-smash" (with hyphen)
- Updated bundle identifiers to "com.djscottyb.stickersmash"
- Removed projectId settings that might be causing conflicts

Modified `eas.json`:
- Added "requireCommit": true to CLI settings
- Removed appVersionSource setting that might be causing conflicts

### 6. Trying configuration again

```bash
npx eas build:configure
```

**Error encountered**: Still getting the Invalid UUID appId error.

### 7. Trying to initialize a new project

```bash
npx eas project:init
```

**Error encountered**: Input prompts not working in this environment
```
Input is required, but stdin is not readable. Failed to display prompt: Which account should own this project?
```

### 8. Trying initialization with the correct command

```bash
npx eas init
```

**Error encountered**: Same issue with interactive prompts
```
Input is required, but stdin is not readable. Failed to display prompt: Which account should own this project?
```

### 9. Manual approach

Since we're having issues with the interactive commands, we're taking a manual approach:

1. Simplified the `eas.json` file to a minimal version
2. Removed advanced features that might cause conflicts
3. Specified the exact CLI version to avoid compatibility issues
4. Disabled requireCommit to allow builds without git commit

### 10. Trying a basic build command

```bash
npx eas build --platform ios --profile development --non-interactive
```

**Error encountered**: CLI version mismatch
```
Error: build command failed.
You are on eas-cli@16.3.1 which does not satisfy the CLI version constraint defined in eas.json (3.16.0).
```

### 11. Fixed CLI version constraint

Updated `eas.json` to use the correct CLI version constraint:
```json
"cli": {
  "version": ">=16.3.0",
  "requireCommit": false
}
```

### 12. Trying build command again

```bash
npx eas build --platform ios --profile development --non-interactive
```

**Error encountered**: Missing expo-dev-client package
```
Error: build command failed.
You want to build a development client build for platforms: iOS
However, we detected that you don't have expo-dev-client installed for your project.
```

### 13. Installing expo-dev-client

```bash
npm install expo-dev-client
```

**Result**: Successfully installed
```
added 8 packages, and audited 1382 packages in 2s
```

### 14. Trying build command again

```bash
npx eas build --platform ios --profile development --non-interactive
```

**Error encountered**: Missing appVersionSource and EAS project not configured
```
Error: build command failed.
The field "cli.appVersionSource" is not set, but it will be required in the future.
EAS project not configured.
```

### 15. Updated eas.json with appVersionSource

Added appVersionSource to eas.json:
```json
"cli": {
  "version": ">=16.3.0",
  "requireCommit": false,
  "appVersionSource": "local"
}
```

### 16. Let's try using a create-project flag

```bash
npx eas build --platform ios --profile development --non-interactive --create-project
```

**Error encountered**: Invalid argument
```
Error: build command failed.
Unexpected argument: --create-project
```

### 17. Manually adding a project ID to app.json

Since we can't use the interactive commands, we've added a manually generated project ID to app.json:

```json
"extra": {
  "eas": {
    "projectId": "8f8daf01-c9d4-4a49-9112-394ccb9f01d8"
  }
}
```

This UUID was manually generated and should enable EAS to associate the app with this project ID.

### 18. Also added expo-dev-client to plugins list in app.json

```json
"plugins": [
  "expo-router",
  "expo-image-picker",
  "expo-media-library",
  "expo-dev-client",
  [
    "expo-splash-screen",
    {
      "image": "./assets/images/splash-icon.png",
      "imageWidth": 200,
      "resizeMode": "contain",
      "backgroundColor": "#ffffff"
    }
  ]
],
```

### 19. Trying build command again

```bash
npx eas build --platform ios --profile development --non-interactive
```

**Error encountered**: Project ID doesn't exist
```
Error: GraphQL request failed.
Experience with id '8f8daf01-c9d4-4a49-9112-394ccb9f01d8' does not exist.
```

### 20. Final outcome and observations

After multiple attempts, we've encountered limitations with trying to automate EAS builds in a non-interactive environment. The EAS CLI appears to require interactive prompts for project creation and initialization, which doesn't work well in environments where stdin is not available for user input.

In a real-world scenario, we'd need to:
1. Create the EAS project through the Expo website or in an interactive terminal first
2. Then copy the actual project ID to the app.json file
3. Use that project ID for non-interactive builds

**Conclusion**: While EAS aims to simplify the build process, it still requires some manual setup steps that can't be fully automated. This contradicts the "one command" ideal that was proposed in the marketing materials.

The primary limitations we encountered:
- Cannot create new EAS projects non-interactively
- Can't initialize a project without interactive prompts
- Manual UUID generation doesn't work because the EAS backend needs to create the project first

For a proper CI/CD workflow, a separate step to initialize the EAS project would be required before automated builds could work.