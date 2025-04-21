const fs = require('fs');
const path = require('path');
const { createCanvas } = require('canvas');

// Ensure the images directory exists
const imagesDir = path.join(__dirname, 'images');
if (!fs.existsSync(imagesDir)) {
  fs.mkdirSync(imagesDir, { recursive: true });
}

// Generate app icon (1024x1024)
function generateAppIcon() {
  const canvas = createCanvas(1024, 1024);
  const ctx = canvas.getContext('2d');
  
  // Background
  ctx.fillStyle = '#25292e';
  ctx.fillRect(0, 0, 1024, 1024);
  
  // Outer circle
  ctx.fillStyle = '#1f2327';
  ctx.beginPath();
  ctx.arc(512, 512, 420, 0, Math.PI * 2);
  ctx.fill();
  
  // Draw sticker emoji icon
  ctx.font = '600px Arial';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('🎯', 512, 512);
  
  // Save the image
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync(path.join(imagesDir, 'icon.png'), buffer);
  console.log('✅ App icon generated');
}

// Generate splash icon (2048x2048)
function generateSplashIcon() {
  const canvas = createCanvas(2048, 2048);
  const ctx = canvas.getContext('2d');
  
  // White background
  ctx.fillStyle = '#FFFFFF';
  ctx.fillRect(0, 0, 2048, 2048);
  
  // Draw app name
  ctx.fillStyle = '#25292e';
  ctx.font = 'bold 160px Arial';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('StickerSmash', 1024, 840);
  
  // Draw sticker emoji
  ctx.font = '400px Arial';
  ctx.fillText('🎯', 1024, 1240);
  
  // Save the image
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync(path.join(imagesDir, 'splash-icon.png'), buffer);
  console.log('✅ Splash icon generated');
}

// Generate adaptive icon for Android (foreground image - 1024x1024)
function generateAdaptiveIcon() {
  const canvas = createCanvas(1024, 1024);
  const ctx = canvas.getContext('2d');
  
  // Transparent background
  ctx.fillStyle = 'rgba(0, 0, 0, 0)';
  ctx.fillRect(0, 0, 1024, 1024);
  
  // Draw sticker emoji (slightly smaller for adaptive icon)
  ctx.font = '700px Arial';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('🎯', 512, 512);
  
  // Save the image
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync(path.join(imagesDir, 'adaptive-icon.png'), buffer);
  console.log('✅ Adaptive icon generated');
}

// Generate favicon for web (192x192)
function generateFavicon() {
  const canvas = createCanvas(192, 192);
  const ctx = canvas.getContext('2d');
  
  // Background
  ctx.fillStyle = '#25292e';
  ctx.fillRect(0, 0, 192,.192);
  
  // Draw sticker emoji (small for favicon)
  ctx.font = '120px Arial';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'middle';
  ctx.fillText('🎯', 96, 96);
  
  // Save the image
  const buffer = canvas.toBuffer('image/png');
  fs.writeFileSync(path.join(imagesDir, 'favicon.png'), buffer);
  console.log('✅ Favicon generated');
}

// Execute all generation functions
try {
  generateAppIcon();
  generateSplashIcon();
  generateAdaptiveIcon();
  generateFavicon();
  console.log('✅ All assets generated successfully');
} catch (error) {
  console.error('Error generating assets:', error);
}