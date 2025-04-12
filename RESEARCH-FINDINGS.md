# EAS Deployment Research Findings

## Executive Summary

This research tested the claim that Expo's EAS (Expo Application Services) provides a "one-command" deployment path to the App Store. Our findings revealed a significant gap between marketing claims and actual implementation. While EAS does simplify certain aspects of iOS deployment, it still requires interactive manual setup steps that cannot be fully automated.

## Methodology

We built a React Native/Expo app called StickerSmash with the following features:
- Photo selection and manipulation
- Sticker overlay functionality 
- Save to camera roll capability
- Memory management and error handling

We then attempted to deploy this app using the EAS workflow, following documentation and claimed best practices.

## Key Findings

### 1. Project Initialization Requires Human Interaction

Despite documentation suggesting complete automation, EAS project creation requires:
- Interactive terminal input
- Manual responses to multiple prompts
- Human decision-making during setup

Commands like `eas init` and `eas build:configure` failed in non-interactive environments, presenting a critical blocker for CI/CD integration.

### 2. Project ID Management

EAS requires a valid project ID that can only be obtained through:
- Interactive terminal workflow
- Web console manual creation
- API calls that require pre-existing credentials

Our attempts to bypass this with manually generated UUIDs consistently failed with API errors.

### 3. Claims vs. Reality Comparison

| Aspect | Marketing Claim | Observed Reality |
|--------|----------------|------------------|
| Setup Complexity | "Simple one-line setup" | Multiple interactive steps across different interfaces |
| Build Process | "One command" | Multiple commands with prerequisites |
| CI/CD Integration | "CI-friendly" | Requires manual preparation before CI can work |
| Cross-Platform | "Build from any OS" | True, but with interactive terminal requirements |

## Challenges Encountered

1. **Non-Interactive Command Failures**:
   ```
   Error: Input is required, but stdin is not readable. Failed to display prompt: Which account should own this project?
   ```

2. **Manual Project ID Rejection**:
   ```
   Error: GraphQL request failed. Experience with id '8f8daf01-c9d4-4a49-9112-394ccb9f01d8' does not exist.
   ```

3. **Missing Automation Flags**:
   ```
   Error: Unexpected argument: --create-project
   ```

## Conclusions

1. **Partial Improvement**: EAS represents an improvement over traditional iOS deployment workflows, particularly in certificate and provisioning profile management.

2. **Two-Phase Requirement**: A viable EAS workflow requires two phases:
   - Manual, interactive setup phase (cannot be automated)
   - Build phase (can be automated after setup)

3. **Documentation Reality Gap**: Marketing materials significantly oversimplify the process, creating unrealistic expectations around automation capabilities.

4. **CI/CD Integration Challenges**: Full CI/CD pipelines will require hybrid approaches with manual preparation steps.

## Recommendations for Future Research

1. Test traditional Xcode approach for comparison
2. Investigate hybrid approaches combining EAS with other tools
3. Document a realistic workflow that acknowledges these limitations 
4. Explore EAS REST API capabilities to potentially bypass CLI limitations
5. Monitor future EAS releases for improvements to automation capabilities

---

*This research was conducted as part of a broader investigation into iOS app deployment methodologies in April 2025.*