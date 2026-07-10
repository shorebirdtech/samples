# 🦅 Shorebird FlutterCon USA Live Demo Guide

This guide provides step-by-step instructions for the team on stage to execute the **Clear Skies** live OTA update demo using Shorebird.

---

## 🛠️ Step 1: Pre-requisites & Setup (Before the Demo)

1. **Clone the Repository**
   Ensure you have the latest code pulled on your presentation machine:
   ```bash
   git clone https://github.com/shorebirdtech/samples.git
   cd samples/clear_skies
   flutter pub get
   ```

2. **Install the Buggy Release APK**
   We have already pre-built the Shorebird release containing the intentional bugs and pushed it to the repository. The APK is located specifically at `samples/clear_skies/output/app-release.apk`. 
   
   You can either drag and drop this file into your emulator, or install it via terminal:
   ```bash
   # Make sure your device/emulator is connected
   adb install output/app-release.apk
   ```

---

## 🎤 Step 2: The Presentation (On Stage)

### 1. Show the "Broken" Production App
1. Open the **Unclear Skies** app on the projector.
2. Point out the hilarious bugs we accidentally shipped to production:
   - The app title says **"Unclear Skies - Discover the world's worst weather"**.
   - The background is a glaring, toxic Neon Green and Bright Red gradient.
   - Tap the **"Tokyo"** popular destination chip, and show how it incorrectly fetches the weather for **Antarctica**.
3. **The Hook:** *"Normally, fixing this means a 2-day wait for App Store / Play Store review. Let's fix this right now with Shorebird."*

### 2. Fix the Code Live
Open your IDE (VS Code / Android Studio) and use **Global Search** for the keyword:
👉 `TODO(Demo)`

This will instantly take you to the three bugs. To fix them, simply uncomment the `CORRECT VERSION` block and comment out or delete the `BUG VERSION` block:

- **Bug 1: `lib/core/constants/app_strings.dart`**
  Uncomment the correct strings for `appName`, `welcomeTitle`, and `welcomeSubtitle` and comment out the buggy ones.

- **Bug 2: `lib/core/constants/app_colors.dart`**
  Uncomment the beautiful sky blue `dayGradient` and comment out the toxic green/red gradient.

- **Bug 3: `lib/features/weather/ui/widgets/welcome_hero_widget.dart`**
  Uncomment the correct `widget.onCityTapped!(city)` and comment out the one hardcoded to `'Antarctica'`.

### 3. Push the Patch via Shorebird
In your terminal, run the patch command to send the fix over the air:

```bash
shorebird patch android
```
*(Wait a few seconds for the patch to build and upload).*

### 4. The Magic Moment 🪄
1. Once the patch is published, go back to the demo device.
2. Force-close the app (swipe it away from recents) and open it again.
3. **Boom!** The toxic green is gone, the title is "Clear Skies", and Tokyo brings up Tokyo's weather. No app store update required!

> [!TIP]
> **Resetting for the Next Booth Demo Loop 🔁** 
> Since this will be demoed continuously at the booth throughout the day, resetting is simple. Just uninstall the app on the device (or clear its data) and re-install the original buggy APK (Step 1.2) to wipe out the downloaded Shorebird patch. Then, revert your local IDE code changes back to the `BUG VERSION` state, and you're ready for the next person!
