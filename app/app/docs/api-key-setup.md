# App Store Connect API Key Setup Guide

This guide explains how to set up an App Store Connect API Key to enable fully automated iOS app deployments with EAS.

## Why Use an API Key?

The App Store Connect API Key enables:
1. **Automated Provisioning**: No need to manually manage certificates and profiles
2. **CI/CD Integration**: Enables headless deployments without user interaction
3. **Secure Authentication**: More secure than using username/password credentials
4. **Limited Access**: Can create keys with specific permissions

## Step-by-Step Setup Process

### 1. Generate the API Key

1. Log in to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to "Users and Access" > "Keys" tab
3. Click the "+" button to create a new key
4. Enter a name for your key (e.g., "EAS Deployment Key")
5. Under "Access," select "App Manager" role (this is the minimum required for app submission)
6. Click "Generate"
7. **IMPORTANT**: Download the key file immediately (you can only download it once)
8. Note the Key ID and Issuer ID displayed on the screen

### 2. Encode the API Key

The API key needs to be base64 encoded for use with EAS:

```bash
# On macOS/Linux
cat /path/to/downloaded/AuthKey_KEYID.p8 | base64

# On Windows (using PowerShell)
[Convert]::ToBase64String([System.IO.File]::ReadAllBytes("C:\path\to\AuthKey_KEYID.p8"))
```

Copy the entire output (it's a long string).

### 3. Store the API Key in EAS

You need to store three secrets in EAS:

```bash
# Add the API Key ID
npx eas-cli secret:create --scope project --name EXPO_APPLE_API_KEY_ID --value "YOUR_KEY_ID" --force

# Add the API Key Issuer ID
npx eas-cli secret:create --scope project --name EXPO_APPLE_API_ISSUER_ID --value "YOUR_ISSUER_ID" --force

# Add the base64-encoded API Key content
npx eas-cli secret:create --scope project --name EXPO_APPLE_API_KEY_CONTENT --value "YOUR_BASE64_ENCODED_KEY" --force
```

Or use our setup script that will guide you through this process:

```bash
./setup-automated-workflow.sh
```

### 4. Additional Required Secrets

You also need to add:

```bash
# Your Apple Developer Team ID (found in Developer Portal)
npx eas-cli secret:create --scope project --name EXPO_APPLE_TEAM_ID --value "YOUR_TEAM_ID" --force

# Your App Store Connect App ID (found in App Store Connect)
npx eas-cli secret:create --scope project --name EXPO_ASC_APP_ID --value "YOUR_APP_ID" --force
```

## Configuring eas.json and Workflows

The API key will be used automatically when:

1. `autoCredentials` is set to `true` in your build profile in `eas.json`
2. The appropriate environment variables are configured in your workflow

Our existing configuration already has these settings properly configured.

## Security Considerations

1. **Key Rotation**: Periodically rotate your API keys (recommended every 90-180 days)
2. **Minimal Permissions**: Use the minimum role required for your needs
3. **Key Management**: Store the key file securely; anyone with the key can access your App Store Connect account
4. **Secret Management**: Never commit the key file or the base64-encoded content to your repository

## Troubleshooting API Key Issues

If you encounter issues with the API key:

1. **Invalid Key**: Ensure the key file was correctly encoded and the full string was copied
2. **Permission Issues**: Verify the API key has the correct role assigned in App Store Connect
3. **Expiration**: Check if the key has expired (they can last up to 1 year)
4. **Revoked Access**: Make sure the key hasn't been revoked in App Store Connect

## Next Steps

Once your API key is set up, you can:

1. Run the setup script to configure your workflows
2. Test a build with `./trigger-deployment.sh`
3. If successful, your app can now be deployed completely automatically!