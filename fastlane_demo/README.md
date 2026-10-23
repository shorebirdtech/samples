# fastlane_demo

A demo app showing how to use [fastlane](https://fastlane.tools/) to release and
patch iOS apps using the
[fastlane-plugin-shorebird](https://rubygems.org/gems/fastlane-plugin-shorebird/)
fastlane plugin.

We recommend reading our [official
docs](https://docs.shorebird.dev/code-push/ci/fastlane/) for context.

This app was created with `flutter create` using Flutter 3.32.2. The Dart code
has not been modified; `pubspec.yaml` only adds the `shorebird.yaml` asset and
sets the build number.

This app's setup largely follows [this
guide](https://medium.com/revelo-tech/setting-up-automatic-ios-release-with-fastlane-and-match-on-ci-cd-server-16c3f1d79bc5),
with Shorebird-specific steps added after completing the steps in the guide.

All fastlane files are located in [`ios/fastlane`](./ios/fastlane/).

The lanes are wired to Shorebird's own Apple account. To run them yourself,
replace Shorebird's values with your own in:

- `ios/fastlane/Matchfile`: the private certificates repo (`git_url`).
- `ios/fastlane/Appfile`: the team names and IDs.
- `ios/fastlane/Fastfile`: `bundle_id`.
- `ios/Runner.xcodeproj/project.pbxproj`: the Runner target's
  `PRODUCT_BUNDLE_IDENTIFIER`, `DEVELOPMENT_TEAM[sdk=iphoneos*]` and
  `PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]` in each build configuration.

A step-by-step log of me (bryanoltman) creating this demo is viewable in
[setup_log.md](./setup_log.md).
