# StickerSmash EAS Deployment Research

This directory contains files related to our research on iOS app deployment methodologies, specifically focusing on transitioning from the EAS CLI approach to the EAS Hub/Workflows approach.

## Research Context

We are exploring different "eras" of iOS app deployment, with StickerSmash serving as our first test case. This research aims to document the reality of deployment processes versus marketing claims, especially for accounts with historical configurations (10+ years).

## Key Files

### Configuration Files
- `eas.json` - Hub-compatible configuration with enhanced build profiles
- `eas-workflows.yml` - Workflow definitions for automated CI/CD

### Documentation
- `HUB-DEPLOYMENT-LOG.md` - Ongoing documentation of the Hub approach experiment
- `HUB-APPROACH-GUIDE.md` - Step-by-step guide for transitioning to the Hub approach
- `CLI-VS-HUB-COMPARISON.md` - Comparative analysis of both deployment methods

### Utilities
- `transition-to-hub.sh` - Helper script for transitioning between approaches

## Previous Research

Our initial CLI-based deployment attempts encountered several limitations:
1. Inability to create projects non-interactively
2. Problems with historical account configurations
3. Manual project ID generation being rejected

The Hub-based approach is our attempt to overcome these limitations through:
1. Visual interfaces instead of command-line prompts
2. Better visibility into account-specific issues
3. Built-in workflow automation

## Running the App

```bash
# Start development server
npx expo start

# Run on iOS simulator
npm run ios
```

## Deployment Options

We've created resources to help you explore different deployment approaches from oldest to newest:

### Option 1: Connect Your Existing App to EAS

If your app isn't yet connected to EAS:

```bash
# Make the script executable
chmod +x connect-existing-app.sh

# Run the connection script (now supports non-interactive mode!)
./connect-existing-app.sh
```

See `CONNECTING-EXISTING-APP.md` for detailed information about this process.

### Option 2: Try the CLI Approach (for connected apps)

For apps already connected to EAS:

```bash
# Make the script executable
chmod +x retry-cli-approach.sh

# Run the script
./retry-cli-approach.sh
```

### Option 3: Use the Hub/Workflows Approach

For team-based workflow automation:

```bash
# Make the transition script executable
chmod +x transition-to-hub.sh

# Run the transition helper
./transition-to-hub.sh
```

Then follow the steps in `HUB-APPROACH-GUIDE.md` to complete the process.

### Option 4: Try the Dashboard-First Approach

A hybrid method that starts with the Expo dashboard:

1. Go to [expo.dev](https://expo.dev) and click "Create a project"
2. Configure project settings and get a project ID
3. Add that ID to your app.json
4. Run `npx eas-cli@latest init --non-interactive` to connect

See `DEPLOYMENT-OPTIONS.md` for more details.

### Option 5: Use Self-Configuring Credentials

A modern approach that eliminates manual certificate management:

1. Generate an App Store Connect API key
2. Configure EAS to use it for automatic credential creation
3. Never worry about provisioning profiles again

See `SELF-CONFIGURING-CREDENTIALS.md` for implementation details.

### Option 6: Use EAS Metadata for App Store Presence

Automate your entire App Store presence:

1. Define all app metadata in `store.config.json`
2. Validate with `eas metadata:validate`
3. Push to App Store with `eas metadata:push`

See `EAS-METADATA-GUIDE.md` and the sample `store.config.json` for implementation.

### Option 7: Use Expo Orbit (Newest Method)

The latest evolution in Expo deployment tools:

1. Download [Expo Orbit](https://expo.dev/orbit)
2. Open your project in Orbit
3. Use one-click build and simulator integration

See `EXPO-ORBIT-GUIDE.md` for comprehensive details.

> ⚠️ **IMPORTANT DISCOVERIES:** 
> 1. Using `--non-interactive --force` flags with EAS CLI commands enables automation even in restricted environments
> 2. Self-configuring credentials with the App Store Connect API eliminate the need for manual certificate management
> 3. EAS Metadata automates the final step of managing App Store presence
> 4. These advancements together create a nearly frictionless deployment pipeline
> 5. All approaches work together to provide a complete solution for accounts with historical configurations

## Research Findings

The comparative findings between approaches will be documented in `CLI-VS-HUB-COMPARISON.md` as the experiments progress. Initial results suggest that the Hub approach may better accommodate accounts with historical configurations.

## App Features

The StickerSmash app itself implements:
- Photo selection with comprehensive permission handling
- Emoji sticker placement with intuitive gestures
- Memory management with automatic cleanup
- Error boundaries for crash protection
- Position constraints to keep stickers in bounds