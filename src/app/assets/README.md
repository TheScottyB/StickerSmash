# Asset Preparation Guide

## Directory Structure

```
assets/
├── images/        # App icons and splash screen images
│   ├── icon.png              # App icon (1024x1024px)
│   ├── splash-icon.png       # Splash screen image (2048x2048px)
│   ├── adaptive-icon.png     # Android adaptive icon (1024x1024px)
│   └── favicon.png           # Web favicon (192x192px)
```

## Asset Requirements for iOS Deployment

1. **App Icon**
   - Primary: 1024x1024px PNG with no transparency
   - iOS automatically generates all required sizes
   - Should be simple, recognizable icon with no text

2. **Splash Screen**
   - Recommended size: 2048x2048px
   - Simple, centered logo on white background
   - Configured in app.json/expo.json

3. **App Store Screenshots**
   - 6.5" Super Retina Display: 1242 x 2688 px
   - 5.5" Display: 1242 x 2208 px
   - 12.9" iPad Pro: 2048 x 2732 px

## Asset Conversion

If needed, convert SVG files to PNG using:

```bash
# If you have ImageMagick installed
convert -background none -size 1024x1024 images/icon.svg images/icon.png
convert -background white -size 2048x2048 images/splash-icon.svg images/splash-icon.png
convert -background none -size 1024x1024 images/adaptive-icon.svg images/adaptive-icon.png
convert -background none -size 192x192 images/favicon.svg images/favicon.png
```

## Notes on Asset Generation

For your final app, ensure all assets:
- Have proper resolution and dimensions
- Are optimized for size
- Contain no transparency where not allowed
- Meet Apple's Human Interface Guidelines