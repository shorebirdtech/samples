# fastlane_demo

A demo app showing how to use [fastlane](https://fastlane.tools/) to release and
patch iOS apps using the
[fastlane-plugin-shorebird](https://rubygems.org/gems/fastlane-plugin-shorebird/)
fastlane plugin.

We recommend reading our [official
docs](https://docs.shorebird.dev/code-push/ci/fastlane/) for context.

This app was created with `flutter create` using Flutter 3.32.2. The Flutter
code has not been modified.

This app's setup largely follows [this
guide](https://medium.com/revelo-tech/setting-up-automatic-ios-release-with-fastlane-and-match-on-ci-cd-server-16c3f1d79bc5),
with Shorebird-specific steps added after completing the steps in the guide.

All fastlane files are located in [`ios/fastlane`](./ios/fastlane/).

The lanes are wired to Shorebird's own Apple account: `Matchfile` points at a
private certificates repo and `Appfile` (and the Xcode project) use Shorebird's
team ID. To run them yourself, replace those with your own match repo, team ID
and bundle identifier.

A step-by-step log of me (bryanoltman) creating this demo is viewable in
[setup_log.md](./setup_log.md).
