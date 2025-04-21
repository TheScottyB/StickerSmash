# App Assets for StickerSmash

This directory contains the placeholder SVG files for the app's visual assets. For your actual app, you'll need to convert these to PNG format.

## Required Assets

1. **icon.png** (1024x1024px)
   - Main app icon used for app stores and the home screen
   - Current: icon.svg needs to be converted to PNG

2. **splash-icon.png** (2048x2048px)
   - Used for the splash screen when the app loads
   - Current: splash-icon.svg needs to be converted to PNG

3. **adaptive-icon.png** (1024x1024px)
   - Used for Android adaptive icons
   - Current: adaptive-icon.svg needs to be converted to PNG

4. **favicon.png** (192x192px)
   - Used for web version
   - Current: favicon.svg needs to be converted to PNG

## Conversion Instructions

To convert these SVG files to the required PNG format, you can use:

1. **Online converters**:
   - Upload the SVG files to a service like [SVG2PNG](https://svgtopng.com/)
   - Download the converted PNGs and place them in this directory

2. **Using Inkscape** (free software):
   - Open the SVG file in Inkscape
   - Go to File > Export PNG Image
   - Set the dimensions (as listed above)
   - Export to this directory

3. **Using Adobe Illustrator**:
   - Open the SVG in Illustrator
   - Go to File > Export > Export As...
   - Choose PNG format and set proper dimensions
   - Save to this directory

4. **Using command line** (if you have ImageMagick installed):
   ```
   convert -background none -size 1024x1024 icon.svg icon.png
   convert -background white -size 2048x2048 splash-icon.svg splash-icon.png
   convert -background none -size 1024x1024 adaptive-icon.svg adaptive-icon.png
   convert -background none -size 192x192 favicon.svg favicon.png
   ```

## Using with Expo

These images are referenced in the app.json file and will be picked up automatically during the build process once converted to PNG format.