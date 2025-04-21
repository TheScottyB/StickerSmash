# Transitioning from EAS CLI to EAS Hub: Step-by-Step Guide

## Prerequisites

- An Expo account (same account used for CLI approach)
- GitHub repository with your React Native/Expo project
- Access to the Apple Developer account for iOS deployment

## Step 1: Connect Your Repository to EAS on the Web Dashboard (REQUIRED)

**IMPORTANT: This step is mandatory and must be performed manually through the web interface. EAS Workflows cannot function without connecting to a GitHub repository.**

1. Log in to your Expo account at [https://expo.dev](https://expo.dev)
2. Navigate to the "Projects" tab
3. Click on "Create a new project" or select an existing project if available
4. In the project settings, find the "GitHub" section
5. Click on "Connect repository" or similar option
6. Follow the prompts to install the Expo GitHub app to your account
7. Select the repository containing your StickerSmash project
8. Authorize the connection

This GitHub connection is essential because:
- EAS Workflows run against code from your GitHub repository
- Build artifacts are associated with specific commits
- Workflow triggers can be based on GitHub events (pushes, PRs)
- The workflow configuration file is read from your repository

## Step 2: Verify Project Configuration

1. Check if your project already has a projectId in app.json:
   ```json
   "extra": {
     "eas": {
       "projectId": "8f8daf01-c9d4-4a49-9112-394ccb9f01d8"
     }
   }
   ```

2. If the manual ID doesn't match the one assigned by the Expo dashboard:
   - Replace it with the actual project ID from the Expo dashboard
   - This ensures the configuration aligns with the Expo backend

## Step 3: Set Up Apple Developer Credentials

1. In the Expo dashboard, navigate to your project
2. Go to "Credentials" tab
3. Select iOS platform
4. Add your Apple Developer credentials:
   - Apple ID
   - Apple Team ID
   - App-specific password (if required)
   - App Store Connect API key (optional but recommended)

5. Verify that the bundle identifier matches what's in your app.json:
   ```json
   "ios": {
     "bundleIdentifier": "com.djscottyb.stickersmash"
   }
   ```

## Step 4: Configure Workflows

1. In your project, create an `eas-workflows.yml` file (already done)
   - This file defines your automated build and deployment processes
   - Includes development, preview, and production workflows

2. Push this file to your GitHub repository
   - The Expo dashboard will detect and display these workflows

3. Ensure your eas.json file has appropriate build profiles that match the workflows:
   ```json
   "build": {
     "development": {
       "developmentClient": true,
       "distribution": "internal",
       "ios": {
         "simulator": true
       }
     },
     "preview": {
       "distribution": "internal"
     },
     "production": {}
   }
   ```

## Step 5: Run Your First Workflow

1. In the Expo dashboard, navigate to your project
2. Go to the "Workflows" tab
3. Select the workflow you want to run (start with development)
4. Click "Run workflow" button
5. Monitor progress directly in the dashboard
6. Download and test the resulting build when complete

## Step 6: Compare with Previous CLI Experience

Document your findings in the HUB-DEPLOYMENT-LOG.md file:
1. How does the setup complexity compare?
2. Did you encounter any issues related to historical account configurations?
3. Was the process more intuitive than the CLI approach?
4. Did you need any interactive terminal inputs?
5. What automation capabilities do workflows offer that CLI didn't?

## Step 7: Set Up Continuous Integration (Optional)

1. Configure workflows to trigger automatically:
   ```yaml
   on:
     push:
       branches:
         - main
     pull_request:
       branches:
         - main
   ```

2. Add workflow status badges to your README.md
3. Configure notifications for workflow events

## Troubleshooting

### Common Issues and Solutions

1. **Project ID Mismatch**
   - Problem: The manually created project ID doesn't match Expo's records
   - Solution: Use the project ID provided by the Expo dashboard

2. **Authentication Failures**
   - Problem: Apple credentials aren't working
   - Solution: Verify credentials in the Expo dashboard and generate new app-specific passwords if needed

3. **Build Configuration Errors**
   - Problem: Workflow fails due to configuration issues
   - Solution: Check logs in the dashboard for specific errors; they're more detailed than CLI errors

4. **Historical Account Complications**
   - Problem: Legacy projects or settings causing conflicts
   - Solution: The dashboard provides visibility into account-wide settings that might be causing issues