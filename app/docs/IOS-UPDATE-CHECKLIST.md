# iOS App Submission Checklist

Use this checklist when preparing to build and submit StickerSmash to the App Store.

## Pre-Submission

### App Configuration

- [ ] **Bundle Identifier**: Verified in app.json (`com.yourcompany.stickersmash`)
- [ ] **Version Number**: Updated in app.json (e.g., `1.0.0`)
- [ ] **Build Number**: Will auto-increment via EAS
- [ ] **Permissions**: All required permissions are included in app.json
- [ ] **Icons & Splash**: All required assets are in the assets folder

### Assets and Content

- [ ] **App Icon**: High-quality 1024x1024px PNG without transparency
- [ ] **Splash Screen**: Simple, clean design that matches app branding
- [ ] **Screenshots**: Prepared for various iOS device sizes
- [ ] **App Preview Video**: Optional, but recommended

### Code and Functionality

- [ ] **Permission Handling**: App gracefully handles permission denials
- [ ] **Memory Management**: App cleans up temporary files
- [ ] **Error Handling**: Proper error boundaries and user-friendly messages
- [ ] **Performance**: App runs smoothly without lag or crashes
- [ ] **Offline Behavior**: App has appropriate offline fallbacks

### Legal and Compliance

- [ ] **Privacy Policy**: URL prepared for App Store submission
- [ ] **Terms of Service**: Optional, but recommended
- [ ] **Data Collection**: Clearly disclosed what data is collected
- [ ] **Attribution**: All third-party libraries and assets properly credited

## Building and Submission

### EAS Configuration

- [ ] **EAS CLI**: Latest version installed (`npm install -g eas-cli`)
- [ ] **EAS Account**: Logged in (`eas login`)
- [ ] **EAS Project**: Configured (`eas build:configure`)

### Build Process

- [ ] **Dependencies**: All dependencies are updated (`npm update`)
- [ ] **Clean Build**: Start with a clean environment (`npm cache clean --force`)
- [ ] **Test Build**: Create a test build first (`eas build --platform ios --profile preview`)
- [ ] **Test Submission**: Test the submission process

### Final Submission

- [ ] **Production Build**: `eas build --platform ios --profile production --auto-submit`
- [ ] **App Store Connect**: Complete all required metadata
- [ ] **Review Notes**: Prepare detailed notes for the App Store review team
- [ ] **Contact Info**: Ensure contact details are up-to-date for review team

## Post-Submission

### Monitoring

- [ ] **Build Status**: Check build status (`eas build:list`)
- [ ] **App Review**: Monitor App Store Connect for review status
- [ ] **Analytics**: Set up appropriate analytics to track installs and usage

### Testing

- [ ] **TestFlight**: Once processed, test the build in TestFlight
- [ ] **Device Testing**: Test on multiple iOS device types and versions
- [ ] **UI Verification**: Ensure all UI elements display correctly

### Marketing and Launch

- [ ] **App Store Optimization**: Keywords and description optimized
- [ ] **Press Kit**: Prepare marketing materials
- [ ] **Launch Plan**: Schedule social media and promotional activities

## Common Rejection Reasons to Avoid

- [ ] Incomplete App Store metadata
- [ ] Bugs and crashes
- [ ] Broken links
- [ ] Misleading descriptions
- [ ] Placeholder content
- [ ] Privacy concerns or inadequate privacy policy
- [ ] Poor user interface or user experience
- [ ] Not enough valuable content
- [ ] Requesting review in the app