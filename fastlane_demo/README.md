# fastlane_demo

A demo app showing how to use [fastlane](https://fastlane.tools/) to release and
patch iOS apps using the
[fastlane-plugin-shorebird](https://rubygems.org/gems/fastlane-plugin-shorebird/)
fastlane plugin.

We recommend reading our [official
docs](https://docs.shorebird.dev/code-push/ci/fastlane/) for context.

This app was created with `flutter create` using Flutter 3.32.2, and its iOS
project was later migrated by Flutter 3.47 (iOS 15 minimum, UIScene lifecycle).
The Dart code has not been modified.

This app's setup largely follows [this
guide](https://medium.com/revelo-tech/setting-up-automatic-ios-release-with-fastlane-and-match-on-ci-cd-server-16c3f1d79bc5),
with Shorebird-specific steps added after completing the steps in the guide.

All fastlane files are located in [`ios/fastlane`](./ios/fastlane/). The fastlane
setup covers iOS only; the Android project is the unmodified template.

The lanes are wired to Shorebird's own accounts. To run them yourself,
replace Shorebird's values with your own in:

- `shorebird.yaml`: the `app_id` (run `shorebird init` to create your own app).
- `ios/fastlane/Matchfile`: the private certificates repo (`git_url`).
- `ios/fastlane/Appfile`: the team names and IDs.
- `ios/fastlane/Fastfile`: `bundle_id`.
- `ios/Runner.xcodeproj/project.pbxproj`: the Runner target's
  `PRODUCT_BUNDLE_IDENTIFIER`, `DEVELOPMENT_TEAM[sdk=iphoneos*]` and
  `PROVISIONING_PROFILE_SPECIFIER[sdk=iphoneos*]` in each build configuration,
  and the RunnerTests target's `PRODUCT_BUNDLE_IDENTIFIER`.

`release_shorebird` sets the build number to one past both the latest TestFlight
build and the latest Shorebird release of the pubspec version (or the pubspec's
build number, if higher), so a release whose upload failed can simply be run
again. It then uploads the build to TestFlight; submit it for review from App
Store Connect. To choose the number yourself, run
`bundle exec fastlane ios release_shorebird build_number:12`. `patch_shorebird` patches the latest release, or
a specific one with `bundle exec fastlane ios patch_shorebird
release_version:1.0.0+11`.

A step-by-step log of me (bryanoltman) creating this demo is viewable in
[setup_log.md](./setup_log.md).
