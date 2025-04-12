# StickerSmash

A React Native app that lets you select photos and add emoji stickers to create fun compositions. Built with Expo.

## Features

- Select photos from your device's library
- Add emoji stickers to your photos
- Move, resize, and rotate stickers using gestures
- Save your creations to your camera roll

## Getting Started

### Prerequisites

- Node.js (LTS version)
- npm or yarn
- Expo CLI: `npm install -g expo-cli`
- EAS CLI: `npm install -g eas-cli`
- [Expo account](https://expo.dev/signup)
- [Apple Developer account](https://developer.apple.com/programs/) (for iOS builds)

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/yourusername/stickersmash.git
   cd stickersmash
   ```

2. Install dependencies:
   ```
   npm install
   ```

3. Start the development server:
   ```
   npx expo start
   ```

## Build and Deploy Process

**⚠️ IMPORTANT: This project uses ONLY the official EAS automated workflow for building and submitting to the App Store. No manual Xcode or other methods should be used, even if issues arise.**

### Development and Testing

1. Configure your project for EAS:
   ```
   eas build:configure
   ```

2. Build for local testing:
   ```
   eas build --platform ios --profile development
   ```

3. Install the development build:
   ```
   # Follow the instructions provided by EAS after the build completes
   ```

### TestFlight Submission

Build and submit to TestFlight in one step:
```
eas build --platform ios --profile preview --auto-submit
```

### App Store Submission

Build and submit to the App Store in one step:
```
eas build --platform ios --profile production --auto-submit
```

## Project Configuration

- `app.json`: Expo configuration 
- `eas.json`: EAS Build configuration
- `/assets`: App assets including icons and splash screens

## App Store Metadata

After submission, you'll need to complete your App Store listing in App Store Connect:

1. **App Information**:
   - Description: Brief explanation of the app's purpose and features
   - Keywords: Terms users might search for to find your app
   - Support URL: Link to support website or email
   - Privacy Policy URL: Required for all apps

2. **App Store Assets**:
   - Screenshots: At least one for each supported device type
   - Preview videos (optional)

3. **App Review Information**:
   - Contact information for the review team
   - Notes for the reviewer explaining how to use the app

## Troubleshooting

If you encounter issues with the build or submission process:

1. Check the EAS build logs:
   ```
   eas build:list
   eas build:view
   ```

2. Validate your app.json and eas.json configurations:
   ```
   npx expo-doctor
   ```

3. Consult the [EAS documentation](https://docs.expo.dev/build/introduction/)

**Remember: Do not attempt to use Xcode or any other manual method to build or submit the app. Follow the EAS workflow exclusively.**

## Changelog

### 2025-04-12
- Backup of index.tsx created before memory/error handling upgrades: app/index_backup.tsx
- Added comprehensive error handling and memory management improvements
- Configured EAS for automated App Store submissions
- Created placeholder assets for app icons and splash screens

## Join the community

- [Expo on GitHub](https://github.com/expo/expo): View the open source platform and contribute.
- [Discord community](https://chat.expo.dev): Chat with Expo users and ask questions.

## License

This project is licensed under the MIT License - see the LICENSE file for details.