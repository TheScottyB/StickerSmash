# EAS Secret and Environment Management

## The Power of Configuration-Free Workflows

One of the most underrated aspects of modern EAS workflows is their ability to manage secrets and environment variables securely across the entire deployment pipeline. This enables "configuration-free" workflow files that contain no actual secrets or environment-specific settings until runtime.

## Secret Management in EAS

### Types of Secrets

EAS provides a sophisticated secret management system with multiple scopes:

1. **Account Secrets**: Available to all projects under your account
   ```bash
   eas secret:create --scope account --name API_KEY --value "secret-value"
   ```

2. **Project Secrets**: Available only to a specific project
   ```bash
   eas secret:create --scope project --name PROJECT_API_KEY --value "project-secret"
   ```

3. **File Secrets**: For certificates, keys, and other file-based secrets
   ```bash
   eas secret:create --scope project --name P8_KEY --type file --value /path/to/key.p8
   ```

### Secret Referencing

Secrets can be referenced in various contexts:

1. **Workflow Environment Variables**:
   ```yaml
   env:
     API_KEY: ${{ secrets.API_KEY }}
   ```

2. **Build-time Environment Variables** (in eas.json):
   ```json
   "build": {
     "production": {
       "env": {
         "API_KEY": "$(EXPO_API_KEY)"
       }
     }
   }
   ```

3. **Configuration Templates**:
   ```json
   "ios": {
     "ascApiKeyId": "${EXPO_APPLE_API_KEY_ID}"
   }
   ```

## GitHub App Integration for Secure CI

The Expo GitHub App enables secure automated builds triggered directly from your repository:

1. **Zero Configuration Needed**: The GitHub App handles authentication automatically
2. **Secure Access Control**: Repository-specific permissions
3. **Branch-Specific Triggers**: Configure build triggers per branch pattern

```yaml
# Example in the Expo Dashboard:
Trigger: Push to branch
Branch pattern: release/*
Platform: iOS
Profile: production
```

## Automatic Build Triggers

The GitHub integration enables several automatic triggers:

1. **Push to Branch**: Build on every commit to specified branches
   ```
   Pattern: main, release/*
   ```

2. **Pull Requests**: Build when PRs are opened or updated
   ```
   Source branch: feature/*
   Target branch: main
   ```

3. **Git Tags**: Build when tags are created
   ```
   Pattern: v*
   ```

## The Configuration-Free Workflow

This combination of features enables truly configuration-free workflows:

### 1. Workflow File with No Secrets or Environment-Specific Settings

```yaml
# eas-workflows.yml
workflows:
  production-release:
    name: iOS Production Release
    jobs:
      build-and-submit:
        env:
          # References to secrets - no actual values here
          EXPO_APPLE_APP_STORE_CONNECT_API_KEY_ID: ${{ secrets.APPLE_API_KEY_ID }}
          EXPO_APPLE_APP_STORE_CONNECT_API_KEY_ISSUER_ID: ${{ secrets.APPLE_API_ISSUER_ID }}
          EXPO_APPLE_APP_STORE_CONNECT_API_KEY_CONTENT: ${{ secrets.APPLE_API_KEY_CONTENT }}
        steps:
          - uses: checkout
          - uses: eas-build
          - uses: eas-submit
          - uses: eas-metadata-push
```

### 2. Secure Build Pipeline

1. **Code Push**: Developer pushes to repository
2. **GitHub Webhook**: Triggers build through GitHub App
3. **Secret Injection**: EAS injects secrets at runtime
4. **Secure Building**: Code built in isolated environment
5. **Deployment**: App deployed to App Store
6. **Cleanup**: Secrets never stored in build artifacts

## Environment Variable Hierarchy

EAS has a sophisticated hierarchy for resolving environment variables:

1. **Workflow Environment Variables**: Highest precedence
2. **EAS Secrets**: Applied based on scope
3. **eas.json Environment Variables**: Per build profile
4. **Repository Environment Variables**: From repository settings
5. **System Environment Variables**: Provided by EAS

## Benefits for Teams

1. **No Shared Secrets**: Team members don't need access to credentials
2. **Version Control Safety**: No secrets in version control
3. **Environment Consistency**: Same workflow file works across environments
4. **Audit Trail**: Secret usage is tracked and logged
5. **Rotation Support**: Update secrets without changing workflow files

## Real-World Scenario: Multiple Environments

A typical setup might include:

1. **Development Environment**:
   - Project ID: dev-project-id
   - API Keys: Development keys
   - Build Profile: development

2. **Staging Environment**:
   - Project ID: staging-project-id
   - API Keys: Staging keys
   - Build Profile: preview

3. **Production Environment**:
   - Project ID: prod-project-id
   - API Keys: Production keys
   - Build Profile: production

With EAS secret management, a single workflow file handles all three environments - the environment-specific configuration is injected at runtime based on the selected build profile and available secrets.

## Conclusion

The secret and environment management capabilities of EAS services transform deployment workflows from brittle, environment-specific scripts to robust, portable definitions. Combined with GitHub integration, this enables true "push to deploy" automation where developers can focus on their code rather than deployment configuration.

This approach represents a fundamental shift from the traditional model where deployment configurations were tightly coupled to specific environments, to a modern model where workflow definitions are environment-agnostic and the appropriate configuration is injected at runtime.