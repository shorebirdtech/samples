# progressive_rollout_demo

This app demonstrates how to implement progressive (percentage-based) patch
rollout using Shorebird's tracks feature.

The guide for this can be found on our [docs
site](https://docs.shorebird.dev/guides/percentage-based-rollouts).

## Running the app (Shorebird employees only)

### Download Firebase Config files

#### Android

Download `google-services.json` for the Android app at
https://console.firebase.google.com/u/0/project/progressive-rollout-demo/settings/general/android:dev.shorebird.progressive_rollout_demo.

This file should be placed at `android/app/google-services.json`.

#### iOS

Download `GoogleService-Info.plist` for the iOS app at
https://console.firebase.google.com/u/0/project/progressive-rollout-demo/settings/general/ios:dev.shorebird.progressive-rollout-demo

This file should be placed at `ios/Runner/GoogleService-Info.plist`.

### Updating Release Percentages

The Cloud Firestore used by this app is at
https://console.firebase.google.com/u/0/project/progressive-rollout-demo/firestore/databases/-default-/data/~2Frollouts~2Frollouts
You can view and edit the rollouts collection there.
