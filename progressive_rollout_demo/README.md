# 📈 Progressive Rollout Demo

This app demonstrates how to implement progressive (percentage-based) patch rollout using Shorebird's tracks feature.

## Running the App

Running this app is the same as running a standard Flutter application. You can use standard `flutter run` commands.

### Firebase Configuration

To run this demo yourself, you will need to set up your own Firebase project:

#### Android
Download `google-services.json` for your Firebase Android app and place it at `android/app/google-services.json`.

#### iOS
Download `GoogleService-Info.plist` for your Firebase iOS app and place it at `ios/Runner/GoogleService-Info.plist`.

### Updating Release Percentages

This demo reads release percentages from Cloud Firestore. You will need to create a `rollouts` collection in your Firestore database to manage the rollout track percentages and view them in your Firebase Console.
