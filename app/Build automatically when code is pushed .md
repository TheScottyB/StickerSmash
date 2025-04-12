Build automatically when code is pushed to repository

You can take your build automation further by automatically building your Expo project when you push code to GitHub.

Set up build triggers

You can set up build triggers to configure when EAS builds your app from GitHub. We allow you to build when pushing to a branch, pull request, and Git tag.

Open your Expo project in the dashboard. To create a build trigger, scroll down to the Build triggers section of the project GitHub settings page and click New Build Trigger.

The build triggers section on the Expo project GitHub settings page
When you click New Build Trigger, you will be presented with a form to configure how this build should run.

These patterns can include wildcards represented by asterisks (*), which can match any character and number of characters inside the pattern. For example, releases/* can match releases/, release/1234, release/genesis, and so on. If you specify the pattern as a sole asterisk (*), all branches/tags will be matched.

The default state of the new build trigger form
You can also configure triggers for specific platforms and build profiles. If you select multiple platforms, a separate trigger will be made for each.

A filled-out version of the new build trigger form
The build triggers section on the Expo project GitHub settings page filled with build triggers
When you push to a branch or tag, you can find the builds by looking at a commit's Checks section.

The GitHub checks section on a branch commit
The GitHub checks section on a tag commit
For pull requests, you can configure a target branch pattern. This is the destination branch of the pull request you want to build. The same rules apply for wildcards here as well.

The build trigger form for pull request
When you push to a pull request with a source and target branch matching this trigger, you'll find these builds in the checks section of the pull request:

The GitHub checks section on a pull request
Note: To trigger builds from a pull request, the pull request's author must be a collaborator on the GitHub repository. If you want to build pull requests from external contributors, apply a PR Label.
Manage build triggers

On your project's GitHub settings page in the Expo dashboard, you can click the options button to the right of a build trigger row to disable, edit, or delete the trigger.

The options button on the build trigger row
You can also run a GitHub build with the parameters from the trigger manually. This will not count towards your automatic build trigger record.

Automatic app stores submission with EAS Submit

Once your build completes, you can automatically submit your app to the app stores using EAS Submit. This feature streamlines the process, reducing the manual steps required to publish your app.

To enable automatic submission, you need to configure your build triggers to include submission as part of the build process. Here's how you can set it up:

Navigate to your project's GitHub settings page on the Expo dashboard.
Find the build trigger you want to modify, and click the options button.
Select Edit trigger and in the dialog that appears, check the option Submit to store after build.
The EAS Submit form fields on the trigger edit form
Save your changes.
An enabled build trigger with automatic submission enabled
Once enabled, every time a build is triggered from this configuration, it will automatically be submitted to the app stores you have configured in your eas.json under the submit field.

Note: Ensure that your eas.json is properly configured for submission, including specifying the correct app store's credentials and submission profile. For more information, see the EAS Submit.
Troubleshooting

When things go wrong, we will comment on the commit we attempted to build with some error information. We also show the latest result in the build triggers UI, which includes error information when you hover the Error tag.
Status UI on the build trigger UI
Double check everything in the Prerequisites section is true when trying to build.
Confirm that your base directory is accurate if you're using a monorepo setup.
Is your build profile correct? If a matching profile can't be found in eas.json, the build will not dispatch.

Previous (EAS Build)
Trigger builds from CI
