# 100% Automated iOS App Deployment Guide

This guide documents how to set up a fully automated build and submission workflow for iOS apps using Expo Application Services (EAS).

## Prerequisites

- Apple Developer Account with App Store Connect access
- App already created in App Store Connect
- Expo Application Services (EAS) account
- Git repository for your app

## Setup Process

### 1. Configure App Store Connect API Key

To enable automated submissions, you need to create an App Store Connect API Key:

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Go to Users and Access > Keys
3. Click the "+" button to create a new key
4. Give it a name like "EAS Deployment Key"
5. Select "App Manager" role (minimum required for submissions)
6. Download the key file (you'll only be able to download it once)
7. Note the Key ID and Issuer ID (you'll need these for EAS configuration)

### 2. Set Up EAS Secret Variables

The following secrets must be configured in EAS:

```bash
# Run the setup script to configure these automatically
./setup-automated-workflow.sh
```

Required secrets:
- `EXPO_APPLE_TEAM_ID`: Your Apple Developer Team ID
- `EXPO_ASC_APP_ID`: Your App Store Connect App ID
- `EXPO_APPLE_API_KEY_ID`: Your App Store Connect API Key ID
- `EXPO_APPLE_API_ISSUER_ID`: Your App Store Connect API Key Issuer ID
- `EXPO_APPLE_API_KEY_CONTENT`: Your App Store Connect API Key content (base64 encoded)

### 3. Configure EAS Workflow

The `eas-workflows.yml` file in this project defines an automated workflow that:

1. Builds the iOS app with the production profile
2. Submits the built app to App Store Connect
3. Updates app metadata in the App Store

The workflow can be triggered:
- Manually: `npx eas-cli workflow:run production-release`
- Automatically: By pushing a Git tag with the pattern `prod-ios-v*`

### 4. Configure Metadata

The `store.config.json` file defines your app's metadata for the App Store, including:
- App description
- Keywords
- Category
- Release notes

### 5. Automated Deployment Options

This project includes two scripts for automated deployment:

#### Setup Script
```bash
./setup-automated-workflow.sh
```
- Verifies all prerequisites are installed
- Sets up required EAS secrets
- Creates and configures necessary workflow files

#### Trigger Script
```bash
./trigger-deployment.sh
```
- Option 1: Start a development build for simulator testing
- Option 2: Trigger a production build and App Store submission manually
- Option 3: Create and push a git tag to trigger a fully automated build and submission

## Workflow Architecture

The automated workflow consists of:

1. **Credential Management**: Using App Store Connect API for automatic provisioning
2. **Build Configuration**: Defined in `eas.json` with profiles for development and production
3. **Workflow Definition**: In `eas-workflows.yml`, defining the build and submit process
4. **Metadata Management**: Using `store.config.json` to automate App Store presence
5. **Trigger Mechanism**: Git tags and manual workflow execution

## Time Estimates

Using this automated approach:
- Development builds: ~5-10 minutes
- Production builds: ~15-20 minutes
- Full end-to-end deployment (build + submission): ~25-30 minutes

Compared to manual processes that can take 2-3 hours, this represents a time savings of approximately 85-90%.

## Best Practices

1. **Version Management**: Increment version numbers in `app.json` before creating new tags
2. **Testing**: Always test builds on development and preview profiles before production
3. **Secret Rotation**: Periodically rotate your App Store Connect API keys for security
4. **Automation**: Use Git tags to trigger builds for consistent, hands-off deployment
5. **Monitoring**: Check the EAS Dashboard for build and submission status

## Troubleshooting

Common issues and solutions:

1. **Build Failures**: Check EAS logs for specific error messages
2. **Submission Rejected**: Ensure App Store Connect API key has sufficient permissions
3. **Workflow Not Triggering**: Verify the git tag pattern matches what's defined in workflows
4. **Authentication Issues**: Re-authenticate with `npx eas-cli login`
5. **Credential Problems**: Try using the `--clean-credentials` flag with build commands

## Additional Resources

- [EAS Workflows Documentation](https://docs.expo.dev/eas/workflows/)
- [App Store Connect API Documentation](https://developer.apple.com/documentation/appstoreconnectapi)
- [EAS Build Documentation](https://docs.expo.dev/build/introduction/)
- [EAS Submit Documentation](https://docs.expo.dev/submit/introduction/)