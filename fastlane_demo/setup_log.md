This document was written in real-time as @bryanoltman set up fastlane with
manual (i.e., not managed by Xcode) app signing and cert/provisioning profile
management. It does not necessarily reflect every step I took, nor has it been
edited for clarity. Start with our guide at
https://docs.shorebird.dev/code-push/ci/fastlane/.

# Problem

Many of our users have problems with iOS signing involving Fastlane. I believe
that we don't see the same issues they do because we let Xcode manage our app
signing, which is a much less common setup among professional app development
teams. I'm going to try setting up signing using fastlane's
[match](https://docs.fastlane.tools/actions/match/) and see what the pain points
are. The resulting app will live in
https://github.com/shorebirdtech/fastlane_demo.

# Log

Following
https://medium.com/revelo-tech/setting-up-automatic-ios-release-with-fastlane-and-match-on-ci-cd-server-16c3f1d79bc5

I attempted to create an apple dev account for contact@. However, this was
unsuccessful because their signup flow would not let me enter a phone number for
2FA. Instead, I am just going to use the certs that already exist and create new
ones with bryan@ if needed, as this is just a proof-of-concept.

Creating a private git repo to store the certs
https://github.com/shorebirdtech/AppleCerts. It's currently empty.

Upgraded fastlane. Following setup guide at https://docs.flutter.dev/deployment/cd#fastlane

The app doesn't build for iOS yet due to signing, that's fine. Going to start
the setup on that platform, as it seems to be the most problematic.

## iOS

Ran `fastlane init`. Opted for manual setup, as the other options required
signin to Apple and I don't think I want to do that as per the guide.

- Filled out fields in ios/Appfile
- Ran `fastlane match init`
- Added `dotenv` gem
- Added `.env.default` and `.env.default.sample`
- Filled out env.default file following the "For CD" instructions.
- Ran `fastlane match nuke distribution`
- Ran `fastlane ios generate_new_certificates`
- Added sync_code_signing step for appstore (distribution) cert

Note that https://github.com/shorebirdtech/AppleCerts now contains info for
our certs and provisioning profiles for the `dev.shorebird.fastlane-demo` app.

- Created an apple API key at https://appstoreconnect.apple.com/access/integrations/api
- Set up fastlane deploy script
- Running `fastlane ios deploy`
  - Failed, needed to create an App entry in Appstore Connect
  - Created, now failing at `upload_to_app_store` step. "No data"
  - Ran `flutter build ipa --release`, error is "exportArchive "Runner.app" requires a provisioning profile."
    - Downloaded profile from app store connect, didn't help
    - Ran "Download Manual Profiles" from Xcode, didn't help
    - I am able to upload the Runner.xcarchive file via Xcode, so this appears
      to just be a "fastlane finding the provisioning profile" issue
  - This failure turned out to be because the app's store metadata was not
    properly configured in App Store Connect.
- Disabled automatic incrementing of version numbers in the build_app step

### Adding Shorebird

- Ran `shorebird init`
- Ran `fastlane add_plugin shorebird`
- Added shorebird_release step
- Running `fastlane ios release_shorebird` seems to be failing because the build
  number is not being properly updated (what is in the pubspec.yaml is not what
  is ending up in the Info.plist file).
  - This seems to be a transient issue, although I'm noticing that the
    `shorebird_release_action` is not locating an .ipa file. The ipa file is also
    not where I'd expect it to be after running `shorebird release` (i.e., in
    ./build/ios/ipa/my_app.ipa)
  - It's not prominently featured, but this is happening because no ipa is being
    generated. The flutter build command can't find a provisioning profile, and
    so it's only creating the xcarchive.
- Shorebird releasing seems to be working, although new builds aren't appearing
  in App Store Connect. I think this is related to IPAs not being produced. The
  [docs for build_app](https://docs.fastlane.tools/actions/build_app/) suggest
  that this command generates an export options plist for you, so we may need to
  do that as part of shorebird_release.
  - Update: this is being done as part of shorebird_release
    (https://github.com/shorebirdtech/fastlane-plugin-shorebird/pull/4)
  - This 0.3.0 of fastlane-plugin-shorebird is now live as of June 13, 2025.
- Added shorebird_patch step. Easy!
