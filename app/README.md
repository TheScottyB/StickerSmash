# StickerSmash: 100% Automated iOS Deployment

This project demonstrates a fully automated build and submission workflow for iOS apps using Expo Application Services (EAS).

## Project Goal

The goal of this project is to create a completely automated workflow for building and submitting iOS apps to the App Store, with zero manual steps needed after initial setup.

## Key Features

- **Fully Automated Builds**: Create dev and production builds with a single command
- **Automated App Store Submission**: Submit builds directly to App Store Connect
- **Self-Configuring Credentials**: Automatic certificate and provisioning profile management
- **Workflow Automation**: Git tag-based triggers for CI/CD pipeline
- **Metadata Management**: Automated App Store presence updates

## Getting Started

### Prerequisites

- Node.js and npm installed
- Expo CLI installed
- EAS CLI installed (v16.3.0+)
- Apple Developer account
- App Store Connect account

### Setup Instructions

1. **Initial Setup**
   ```bash
   # Run the setup script to configure everything
   ./setup-automated-workflow.sh
   ```

2. **Configure App Store Connect API Key**
   
   Follow the instructions in `api-key-setup.md` to create and configure your App Store Connect API Key.

3. **Trigger a Deployment**
   
   ```bash
   # Run the deployment trigger script
   ./trigger-deployment.sh
   ```

## Project Structure

- `app/`: App source code
- `eas.json`: EAS build configuration
- `eas-workflows.yml`: Workflow automation definition
- `store.config.json`: App Store metadata configuration
- `setup-automated-workflow.sh`: Setup script for initial configuration
- `trigger-deployment.sh`: Script to trigger automated deployments
- `AUTOMATION-GUIDE.md`: Detailed documentation on the automation workflow
- `api-key-setup.md`: Guide for setting up App Store Connect API Key

## Configuration Files

- **eas.json**: Defines build profiles for development, preview, and production with `autoCredentials: true`
- **eas-workflows.yml**: Configures the automated workflow that builds and submits to the App Store
- **app.json**: Contains app metadata, bundle identifiers, and permissions
- **store.config.json**: Defines App Store metadata for automated store presence updates

## Deployment Options

This project supports three deployment options:

1. **Development Build**: Build for iOS simulator
   ```bash
   ./trigger-deployment.sh
   # Select option 1
   ```

2. **Manual Production Build**: Build and submit to App Store with a single command
   ```bash
   ./trigger-deployment.sh
   # Select option 2
   ```

3. **Fully Automated Deployment**: Triggered by Git tags
   ```bash
   ./trigger-deployment.sh
   # Select option 3
   # Enter version number when prompted
   ```

## Documentation

- [Automation Guide](./AUTOMATION-GUIDE.md): Complete documentation of the automated workflow
- [API Key Setup](./api-key-setup.md): Instructions for setting up App Store Connect API Keys

## App Features

The StickerSmash app itself implements:
- Photo selection with comprehensive permission handling
- Emoji sticker placement with intuitive gestures
- Memory management with automatic cleanup
- Error boundaries for crash protection
- Position constraints to keep stickers in bounds

## Time Savings

Using this automated approach saves approximately 85-90% of the time traditionally spent on iOS deployment:

| Task | Manual Time | Automated Time |
|------|-------------|----------------|
| Certificate/Profile Management | 30-60 mins | 0 mins |
| Build Configuration | 15-30 mins | 0 mins |
| Build Process | 15-20 mins | 15-20 mins |
| App Store Submission | 30-60 mins | 5-10 mins |
| Metadata Updates | 15-30 mins | 0 mins |
| **Total** | **105-200 mins** | **20-30 mins** |

## Important Discoveries

1. Using `--non-interactive --force` flags with EAS CLI commands enables complete automation
2. Self-configuring credentials with the App Store Connect API eliminates manual certificate management
3. EAS Workflows provide a declarative way to define the entire build and submit process
4. Git tag-based triggers enable true "push to deploy" functionality
5. These advancements create a nearly frictionless deployment pipeline for iOS apps

## Running the App Locally

```bash
# Start development server
npx expo start

# Run on iOS simulator
npm run ios
```

## Further Reading

- [EAS Documentation](https://docs.expo.dev/eas/)
- [App Store Connect API](https://developer.apple.com/documentation/appstoreconnectapi)
- [Expo Workflows](https://docs.expo.dev/eas/workflows/)