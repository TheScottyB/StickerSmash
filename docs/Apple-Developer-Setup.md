# Apple Developer Account Setup for StickerSmash

This guide covers the essential steps to configure your Apple Developer account for building and publishing the StickerSmash app to TestFlight and the App Store.

## 1. Prerequisites

- Apple Developer Program membership ($99/year)
- Mac computer with Xcode 15+ installed
- EAS CLI installed (`npm install -g eas-cli`)

## 2. Configure Apple Developer Account

### 2.1 Create App ID (Bundle Identifier)

1. Go to [Apple Developer Portal](https://developer.apple.com/)
2. Navigate to **Certificates, IDs & Profiles**
3. Select **Identifiers** in the sidebar
4. Click the **+** button to register a new App ID
5. Choose **App IDs** and click **Continue**
6. Select **App** as the type and click **Continue**
7. Enter:
   - Description: "StickerSmash"
   - Bundle ID: "com.yourcompany.stickersmash" (must match app.json)
8. Check capabilities needed:
   - **Access WiFi Information**
   - **Associated Domains** (if using universal links)
   - **Push Notifications** (if needed)
9. Click **Continue** and then **Register**

### 2.2 Create Development & Distribution Certificates

1. In Apple Developer Portal, navigate to **Certificates, IDs & Profiles**
2. Select **Certificates** in the sidebar
3. Click **+** to create a new certificate
4. For development:
   - Select **Apple Development** (for device testing)
5. For distribution:
   - Select **Apple Distribution** (for App Store)
6. Follow on-screen instructions to create CSR and upload it
7. Download and double-click to install certificates in Keychain

### 2.3 Register Test Devices (for development)

1. In Apple Developer Portal, navigate to **Devices**
2. Click **+** to add test device
3. Enter name and UDID of the device
4. Click **Continue** and **Register**

### 2.4 Create Provisioning Profiles

1. In Apple Developer Portal, navigate to **Profiles**
2. Click **+** to create a new profile
3. For development:
   - Select **iOS App Development**
   - Select your App ID (StickerSmash)
   - Select your development certificate
   - Select test devices
4. For distribution:
   - Select **App Store** 
   - Select your App ID (StickerSmash)
   - Select your distribution certificate
5. Name your profiles descriptively (e.g., "StickerSmash Development", "StickerSmash Distribution")
6. Generate, download, and double-click to install profiles

## 3. Create App Store Connect Listing

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to **Apps**
3. Click the **+** button and select **New App**
4. Fill in the details:
   - Platform: iOS
   - Name: "StickerSmash"
   - Primary language: English (or your target language)
   - Bundle ID: Select your registered bundle ID
   - SKU: A unique identifier (e.g., "stickersmash2025")
5. Click **Create**

## 4. Complete App Store Information

In your new App Store listing, complete:

1. **App Information**
   - Privacy Policy URL
   - Category (Entertainment or Photo & Video)

2. **Pricing and Availability**
   - Price: Free (or your price tier)
   - Available territories

3. **App Review Information**
   - Contact details
   - Login information (if needed for review)
   - Notes for reviewers

## 5. Update EAS Configuration

Edit your `eas.json` file with your Apple account details:

```json
"submit": {
  "production": {
    "ios": {
      "appleId": "your-apple-id@example.com",
      "ascAppId": "1234567890", // App ID from App Store Connect
      "appleTeamId": "ABCDEF1234" // Team ID from Developer Portal
    }
  }
}
```

## 6. Update App Configuration

Update `app.json` with proper iOS-specific settings:

```json
"ios": {
  "bundleIdentifier": "com.yourcompany.stickersmash",
  "buildNumber": "1",
  "infoPlist": {
    "NSPhotoLibraryUsageDescription": "This app needs access to your photos to let you select images for stickers and save your creations.",
    "NSPhotoLibraryAddUsageDescription": "This app needs access to save your sticker creations to your photo library.",
    "NSCameraUsageDescription": "This app needs camera access to let you take photos for stickers."
  }
}
```

## 7. Build and Submit

### Development Build:
```
eas build --profile development --platform ios
```

### TestFlight Build:
```
eas build --profile preview --platform ios
```

### App Store Build & Submit:
```
eas build --profile production --platform ios
eas submit -p ios --latest
```

## 8. TestFlight Configuration

After your build is processed in App Store Connect:

1. Navigate to your app in App Store Connect
2. Select **TestFlight** tab
3. Add testers:
   - Internal (limited to your team members)
   - External (requires App Review approval)
4. Configure test information, including what to test
5. Invite testers via email

## 9. Common Issues and Solutions

- **Certificate/Profile Mismatch**: Ensure development certificates match development profiles, and distribution certificates match distribution profiles
- **UDID Not Recognized**: Double-check device UDID is correct and added to your development profile
- **Push Notification Issues**: Ensure you have a Push Notification certificate if using push notifications
- **App Icon Rejected**: Ensure app icon meets Apple's guidelines (no transparency, proper dimensions)
- **App Rejection**: Review Apple's [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/) before submission

## 10. Helpful Resources

- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Expo EAS Documentation](https://docs.expo.dev/build/setup/)
- [TestFlight Documentation](https://developer.apple.com/testflight/)