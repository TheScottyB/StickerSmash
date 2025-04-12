# Automatic Build Triggers with EAS and GitHub

## True "Push to Deploy" with EAS Build Triggers

One of the most powerful aspects of the EAS and GitHub integration is the ability to automatically trigger builds and deployments based on repository events, creating a true "push to deploy" workflow.

## Setting Up Build Triggers

### 1. Prerequisites

- GitHub repository connected to Expo project
- EAS workflows configured
- GitHub App installed on repository

### 2. Where to Configure

Build triggers are configured in the Expo Dashboard:
1. Open your project on [expo.dev](https://expo.dev)
2. Navigate to Project Settings > GitHub
3. Scroll to the "Build Triggers" section
4. Click "New Build Trigger"

## Types of Triggers

### 1. Push to Branch

Automatically build when code is pushed to specific branches:

```
Trigger: Push to branch
Branch pattern: main
Platform: iOS
Profile: production
```

You can use wildcards for branch patterns:
- `main` - Only the main branch
- `release/*` - Any branch starting with "release/"
- `*` - Any branch

### 2. Pull Requests

Build when PRs are opened or updated:

```
Trigger: Pull Request
Source branch: feature/*
Target branch: main
Platform: iOS
Profile: development
```

This is especially useful for:
- Testing changes before merging
- Ensuring code builds properly
- Preview builds for stakeholders

### 3. Git Tags

Build when tags are created:

```
Trigger: Git Tag
Tag pattern: v*
Platform: iOS
Profile: production
Submit to Store: Yes
```

Perfect for release automation:
- Tag format `v1.2.3` triggers build
- Build is automatically submitted to App Store
- No manual intervention needed

## Automatic Submission

For any trigger type, you can enable automatic app submission:

```
Trigger: Git Tag
Tag pattern: v*
Platform: iOS
Profile: production
Submit to Store: Yes
```

When enabled:
1. Build completes
2. EAS Submit is automatically triggered
3. App is submitted to App Store
4. Metadata is pushed from store.config.json

## Viewing Build Status

Build status appears directly in GitHub:

1. **Commit Status**: On branches or tags
2. **Check Status**: In pull requests
3. **Status Badges**: Can be added to README

## Example: Complete Release Workflow

Here's a complete workflow for an iOS app:

1. **Development Builds**:
   ```
   Trigger: Push to branch
   Branch pattern: develop
   Platform: iOS
   Profile: development
   Submit to Store: No
   ```

2. **Test Builds**:
   ```
   Trigger: Pull Request
   Source branch: feature/*
   Target branch: main
   Platform: iOS
   Profile: preview
   Submit to Store: No
   ```

3. **Release Builds**:
   ```
   Trigger: Git Tag
   Tag pattern: v*
   Platform: iOS
   Profile: production
   Submit to Store: Yes
   ```

## Developer Experience

With this setup, the developer workflow becomes:

1. **Feature Development**:
   - Work on feature branch
   - Push changes - dev builds automatically created
   - Open PR - test builds automatically created

2. **Release**:
   - Merge PR to main
   - Create tag `v1.2.3`
   - Tag triggers production build and App Store submission
   - No manual build or submission steps

## Security Considerations

1. **External Contributors**:
   - By default, PRs from non-collaborators don't trigger builds
   - Can be enabled by applying PR label

2. **Secret Access**:
   - Secrets remain protected even during PR builds
   - Environment variables properly scoped

3. **Build Permissions**:
   - Can restrict who can create manual builds
   - Audit trail for all triggered builds

## Conclusion

The automatic build triggers with GitHub integration transform the deployment process into a true GitOps workflow. Developers can focus entirely on code, with the deployment pipeline handling the rest automatically. This enables a development experience where pushing code to the right branch or creating a tag is all that's needed to deploy to any environment, including the App Store.