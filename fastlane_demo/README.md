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

## Lanes

Run these from `ios/` with `bundle exec fastlane ios <lane>`. They read
credentials from `ios/fastlane/.env.default` (see
[`.env.default.sample`](./ios/fastlane/.env.default.sample)).

- `certificates`: fetches the development and App Store signing certificates
  and profiles with match, read-only.
- `generate_new_certificates`: creates them with match if needed.
- `release_shorebird`: creates a Shorebird release and uploads it to
  TestFlight; submit it for review from App Store Connect. The build number is
  one past both the latest TestFlight build and the latest Shorebird release of
  the pubspec version (or the pubspec's build number, if higher), so a release
  whose upload failed can simply be run again. A rerun creates a new release,
  so delete the one whose upload failed with `shorebird releases delete` to
  keep it from being patched. On CI it uses the App Store Connect API key;
  locally, without one, fastlane signs in with the Apple ID in `FASTLANE_USER`
  (or asks for it).
- `patch_shorebird`: patches the release you name, normally the one in the App
  Store: `bundle exec fastlane ios patch_shorebird release_version:1.0.0+11`.
  `release_version:latest` patches the most recently updated release instead.

A step-by-step log of me (bryanoltman) creating this demo is viewable in
[setup_log.md](./setup_log.md).
