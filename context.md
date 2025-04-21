# StickerSmash Project Context

## Project Overview
StickerSmash is a mobile application built with Expo and React Native that allows users to create and save custom stickers using images from their device. The app demonstrates modern React Native development practices with Expo's managed workflow.

## Architecture & Technology Stack

### Core Framework
- **Expo SDK**: 52.0.44
- **React**: 18.3.1
- **React Native**: 0.79.0
- **TypeScript**: For type-safe development

### Navigation & Routing
- **expo-router**: File-based routing system
- **@react-navigation/bottom-tabs**: Tab-based navigation
- **@react-navigation/native**: Navigation foundation

### UI & UX Components
- **expo-blur**: For visual blur effects
- **expo-haptics**: For haptic feedback
- **@expo/vector-icons**: Icon library
- **expo-symbols**: Additional symbol assets
- **expo-status-bar**: Status bar customization

### Image & Media Handling
- **expo-image-picker**: For selecting images from device library
- **expo-image-manipulator**: For image editing capabilities
- **expo-media-library**: For saving creations to device
- **react-native-view-shot**: For capturing views as images

### Animation & Gestures
- **react-native-reanimated**: Advanced animations
- **react-native-gesture-handler**: Touch handling

## Features
- Image selection from device library
- Camera integration for capturing new images
- Sticker creation and customization
- Saving creations to device gallery
- Cross-platform support (iOS, Android, Web)
- Responsive design with automatic theme adaptation

## Project Structure
```
StickerSmash/
├── .github/               # GitHub workflows and configuration
├── assets/                # Static assets
├── MyStickersApp/         # Main application code
│   ├── app/               # expo-router based navigation
│   │   ├── (tabs)/        # Tab-based navigation routes
│   │   │   ├── _layout.tsx
│   │   │   ├── explore.tsx
│   │   │   └── index.tsx
│   │   ├── _layout.tsx    # Root layout component
│   │   └── +not-found.tsx # 404 page
│   ├── components/        # Reusable UI components
│   ├── constants/         # App constants (colors, etc.)
│   ├── hooks/             # Custom React hooks
│   └── scripts/           # Utility scripts
├── scripts/               # Project management scripts
├── src/                   # Additional source code
└── app.json               # Expo configuration
```

## Key Configurations

### App Information
- **Name**: MyStickersApp
- **Bundle ID (iOS)**: com.djscottyb.mystickersapp
- **Package (Android)**: com.djscottyb.mystickersapp
- **Version**: 1.0.0
- **Owner**: avallon-technologies-llc

### Build Configuration
- New React Native architecture enabled (`newArchEnabled: true`)
- EAS Build configuration in `eas.json`
- EAS Project ID: mystickers-1744488311
- Runtime Version: 1.0.0

### Permissions
- **iOS**:
  - Photo Library access (read/write)
  - Camera access
  - Full screen requirement
  - Non-exempt encryption declaration

- **Android**:
  - External storage (read/write)
  - Camera
  - Audio recording

### Development & Testing
- Jest for unit testing
- expo-dev-client for enhanced development workflow
- TypeScript for static type checking

## Development Workflow
- **Start Development**: `yarn start` or `expo start`
- **Run on iOS**: `yarn ios` or `expo run:ios`
- **Run on Android**: `yarn android` or `expo run:android`
- **Web Development**: `yarn web` or `expo start --web`
- **Testing**: `yarn test`
- **Linting**: `yarn lint`
- **Reset Project**: `yarn reset-project`

## Deployment
- Uses EAS (Expo Application Services) for building and publishing
- OTA updates configured via expo-updates
- Update URL: https://u.expo.dev/3a3a91cf-6327-4d09-92a0-ab4bbefd3c62

## Additional Notes
- The project has recently undergone a major restructuring, moving from a native-focused approach to a more Expo-centric structure
- The repository contains both the active application code and historical documentation in the src/app/docs directory

