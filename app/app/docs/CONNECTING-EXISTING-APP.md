# Connecting an Existing App to EAS

This guide specifically addresses how to connect an existing React Native/Expo app (like our StickerSmash app) to EAS. This differs from creating a new app from scratch.

## Background

When you have an existing app (perhaps developed before EAS or without previous EAS integration), you need to connect it to EAS rather than create a new project. This process registers your existing codebase with EAS services.

## Prerequisites

- An existing React Native/Expo app (StickerSmash in our case)
- The app code in a GitHub repository
- An Expo account

## Step 1: Prepare Your Existing App

1. Ensure your app has a valid `app.json` file with:
   - `name`: Your app name
   - `slug`: A unique identifier (kebab-case)
   - `owner`: (optional) Your Expo account name
   
2. Check your package.json has Expo SDK dependencies

## Step 2: Login to Expo

```bash
# Login to your Expo account
npx eas-cli@latest login
```

## Step 3: Register Your Existing App with EAS

Instead of creating a new app, run:

```bash
# Initialize EAS for your existing project
npx eas-cli@latest init
```

During this process:
- You'll be asked which account should own the project
- You'll select whether to create a new project or use an existing one
- The CLI will assign an EAS Project ID to your app

## Step 4: Update app.json with the Project ID

After initialization, check that your app.json has been updated with a projectId:

```json
"extra": {
  "eas": {
    "projectId": "assigned-project-id"
  }
}
```

If not, you'll need to manually add the projectId that was assigned.

## Step 5: Connect to GitHub (for EAS Workflows)

For EAS Workflows to work, you must connect your GitHub repository:

1. Go to [expo.dev](https://expo.dev)
2. Find your newly registered project
3. Navigate to project settings
4. Find the GitHub section
5. Click "Connect Repository"
6. Install the Expo GitHub App when prompted
7. Select your repository containing StickerSmash code
8. Authorize the connection

## Step 6: Verify Connection

To verify your app is properly connected:

```bash
# Check project status
npx eas-cli@latest project:info
```

This should display your project details including the assigned ID and connected status.

## Troubleshooting Common Issues

### "Project not found" Error

If you get "project not found" errors after initialization:
1. Verify the projectId in app.json matches what's shown in the Expo dashboard
2. Check if the app slug matches what's registered with EAS
3. Try running `npx eas-cli@latest configure` to reset the configuration

### Account History Issues

For accounts with 10+ years of history:
1. Check if you have duplicate apps with the same name
2. Verify ownership permissions for the organization
3. Try creating a new standalone project in the dashboard first, then linking your local code

### GitHub Connection Issues

If GitHub connection fails:
1. Ensure you're an admin of the repository
2. Check that the GitHub app has the necessary permissions
3. Try disconnecting and reconnecting the repository

## Next Steps

Once your existing app is connected to EAS, you can proceed with:
- Configuring build profiles in eas.json
- Creating workflow configurations
- Running your first build

Follow the standard Hub approach documentation from this point.