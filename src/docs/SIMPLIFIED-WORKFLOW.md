# Simplified EAS Workflow with API Key

This document provides a streamlined, step-by-step guide to the optimal EAS deployment workflow using App Store Connect API and GitHub integration.

## Prerequisites

- An Apple Developer account
- An Expo account
- A GitHub repository containing your React Native/Expo project
- Access to App Store Connect

## 1. Generate App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to Users and Access > Keys
3. Click "+" to create a new API key
4. Set name (e.g., "EAS Deployment")
5. Set Access: App Manager role
6. Download the API key (.p8 file) - you only get one chance!
7. Note the Key ID and Issuer ID

## 2. Connect GitHub Repository to Expo

1. Log in to [Expo Dashboard](https://expo.dev)
2. Create a new project or select existing project
3. Go to project settings
4. Select "GitHub" tab
5. Click "Connect Repository"
6. Install Expo GitHub App for your repository
7. Select the repository
8. Authorize access

## 3. Configure Project Files

### Update app.json
```json
{
  "expo": {
    "name": "YourAppName",
    "slug": "your-app-slug",
    "owner": "your-expo-username",
    "ios": {
      "bundleIdentifier": "com.yourcompany.yourapp"
    }
  }
}
```

### Create eas.json
```json
{
  "cli": {
    "version": ">=16.3.0",
    "requireCommit": false,
    "appVersionSource": "local"
  },
  "build": {
    "development": {
      "developmentClient": true,
      "distribution": "internal",
      "ios": {
        "simulator": true
      },
      "channel": "development",
      "autoIncrement": false,
      "autoCredentials": true,
      "credentialsSource": "remote"
    },
    "preview": {
      "distribution": "internal",
      "ios": {
        "simulator": false,
        "resourceClass": "m1-medium"
      },
      "channel": "preview",
      "autoIncrement": true,
      "autoCredentials": true, 
      "credentialsSource": "remote"
    },
    "production": {
      "distribution": "store",
      "ios": {
        "resourceClass": "m1-medium"
      },
      "channel": "production",
      "autoIncrement": true,
      "autoCredentials": true,
      "credentialsSource": "remote"
    }
  },
  "submit": {
    "production": {
      "ios": {
        "ascAppId": "${EXPO_ASC_APP_ID}",
        "appleTeamId": "${EXPO_APPLE_TEAM_ID}"
      }
    }
  },
  "extend": {
    "workflows": true
  }
}
```

### Create eas-workflows.yml
```yaml
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
```

### Create store.config.json
```json
{
  "expo": {
    "name": "YourAppName",
    "stores": {
      "ios": {
        "ascApiKeyId": "${EXPO_APPLE_API_KEY_ID}",
        "ascApiKeyIssuerId": "${EXPO_APPLE_API_ISSUER_ID}",
        "ascApiKeyPath": "${EXPO_APPLE_API_KEY_PATH}"
      }
    },
    "appStoreConfig": {
      "categoryType": "utilities",
      "description": "Your app description here",
      "keywords": ["keyword1", "keyword2"],
      "releaseNotes": "Initial release"
    }
  }
}
```

## 4. Set Up API Key in Expo Secrets

```bash
# Store your API key details as secrets
eas secret:create --scope project --name APPLE_API_KEY_ID --value "YOUR_KEY_ID"
eas secret:create --scope project --name APPLE_API_ISSUER_ID --value "YOUR_ISSUER_ID"
eas secret:create --scope project --name APPLE_API_KEY_CONTENT --type file --value /path/to/your/key.p8
```

## 5. Test Your Setup

```bash
# Initialize the project (only needed for new projects)
npx eas-cli@latest init --non-interactive --force

# Validate your metadata (optional)
npx eas-cli@latest metadata:validate

# Run a build to verify credentials work
npx eas-cli@latest build --platform ios --profile development --non-interactive
```

## 6. Trigger Workflow

1. Go to your project on [Expo Dashboard](https://expo.dev)
2. Navigate to "Workflows" tab
3. Select "production-release" workflow
4. Click "Run workflow"
5. Monitor progress in the dashboard

## What Happens Behind the Scenes

1. **Auto Credentials**: EAS uses your API key to:
   - Generate a new certificate if needed
   - Create appropriate provisioning profiles
   - Handle all code signing automatically

2. **Build Process**: The workflow:
   - Checks out your GitHub repository
   - Sets up the build environment
   - Builds your app
   - Signs it with the auto-generated credentials

3. **Submission**: After building:
   - App is submitted to App Store Connect
   - Metadata is pushed from your store.config.json
   - Assets are uploaded (screenshots, etc.)

## Troubleshooting

- **API Key Issues**: Ensure key has App Manager permissions and isn't expired
- **GitHub Connection**: Check that repo has the correct access for the Expo GitHub App
- **Build Failures**: Check logs in Expo dashboard for detailed error messages
- **Submission Failures**: Verify app metadata matches App Store guidelines

## Benefits

- **Zero Certificate Management**: Never deal with provisioning profiles
- **Fully Automated**: End-to-end build and submit process
- **Trackable**: All configs in version control
- **Team-Friendly**: No sharing of certificates or credentials
- **Idempotent**: Same workflow works across environments
- **Optimized Builds**: Configure iOS resource classes for faster builds
- **Auto Versioning**: Automatic build number incrementation
- **Workflow Integration**: Extend EAS capabilities with custom workflows

This streamlined workflow eliminates nearly all manual steps in the iOS deployment process, allowing you to focus on building your app rather than managing deployment complexities.
