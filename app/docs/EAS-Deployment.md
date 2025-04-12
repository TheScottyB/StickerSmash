# EAS Deployment Guide for StickerSmash

This document provides detailed instructions for deploying StickerSmash to the App Store using the fully automated EAS workflow.

## Prerequisites

- EAS CLI installed: `npm install -g eas-cli`
- Expo account with access to EAS Build
- Apple Developer account

## Initial Setup

### 1. Login to EAS

```bash
eas login
```

### 2. Configure Your Project

```bash
eas build:configure
```

This command will add the necessary configuration files and ensure your project is ready for EAS builds.

## Building for Different Environments

### Development Build (for testing on device)

A development build includes development tools and allows for easier debugging:

```bash
eas build --platform ios --profile development
```

This build can be installed on:
- iOS simulator
- Physical iOS devices registered in your Apple Developer account

### Preview Build (for TestFlight)

For internal testing via TestFlight:

```bash
eas build --platform ios --profile preview --auto-submit
```

This:
- Creates an App Store build
- Automatically uploads to TestFlight
- Handles all certificate and provisioning profile management
- Sets up the App Store Connect entry if it doesn't exist

### Production Build (for App Store)

When you're ready to submit to the App Store:

```bash
eas build --platform ios --profile production --auto-submit
```

The `--auto-submit` flag handles:
- Building the app
- Creating App Store Connect listing if needed
- Submitting for review

## Advanced Configuration

### Auto-incrementing Build Numbers

We've enabled auto-incrementing build numbers in eas.json:

```json
"production": {
  "autoIncrement": true,
  "channel": "production"
}
```

This ensures each build has a unique build number without manual intervention.

### App-Specific Passwords

If you have two-factor authentication enabled (recommended):

```bash
eas credentials --platform ios
```

Follow the prompts to set up an app-specific password.

## Post-Submission Steps

After submission, you still need to complete your App Store listing:

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to your app
3. Complete the required information:
   - App description
   - Keywords
   - Support URL
   - Privacy Policy URL
   - Screenshots (at least one for each device type)
   - Age rating
   - Review notes

## Helpful Commands

### View Build Status

```bash
eas build:list
```

### View Build Details

```bash
eas build:view
```

### Update Credentials

```bash
eas credentials
```

### View Submit History

```bash
eas submit:list
```

## Troubleshooting

### Building Locally for Testing

If you're having issues with EAS builds:

```bash
expo run:ios
```

This command builds the project locally, which can help identify if the issue is with your code or the EAS service.

### Common Issues

- **Build Failures**: Check `eas build:view` for detailed logs
- **Submission Failures**: Ensure your app meets Apple's guidelines
- **Permission Issues**: Double-check iOS privacy descriptions in app.json
- **Asset Problems**: Verify all assets meet Apple's requirements
- **Rejection**: Carefully read Apple's rejection reason and address the specific issues

## Key Resources

- [EAS Build Documentation](https://docs.expo.dev/build/introduction/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Expo Forums](https://forums.expo.dev/)