# EAS Hub Deployment Log

Date: April 12, 2025

## Overview

This document tracks our experiment transitioning from the EAS CLI deployment approach to the EAS Hub/Workflows approach. After encountering limitations with the CLI method, especially for accounts with historical configurations, we're testing if the Hub approach resolves these issues.

## Initial Setup

1. Starting with the existing StickerSmash project (after CLI deployment failed)
2. Using the same Expo account with 10+ years of history
3. Testing whether the Hub approach handles historical account configurations better

## Hub Approach Strategy

### Key Differences from CLI Approach:
- Web dashboard-based project creation instead of CLI commands
- Visual workflow configuration vs. command-line parameters
- Direct connection to GitHub/repository vs. local deployment
- Workflow automation capabilities not available via CLI

### Expected Benefits:
- Avoids interactive terminal requirements
- Potentially better handling of account-specific configurations
- More discoverable interface for resolving issues
- Ability to visualize and manage the deployment process

## Implementation Plan

1. Modify existing configuration files if needed
2. Create workflow configuration files
3. Connect to the Expo web dashboard
4. Set up the build workflow
5. Test build and deployment process
6. Document comparisons to CLI approach

## Initial Configuration

The project currently has:
- A manually generated projectId in app.json
- Basic build profiles in eas.json
- Placeholder credentials in the submit section

Our first step is to verify if these configurations are compatible with the Hub approach or require modifications.