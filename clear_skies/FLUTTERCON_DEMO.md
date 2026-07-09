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

This will instantly take you to the three bugs. Revert them back to their correct state:

- **Bug 1: `lib/core/constants/app_strings.dart`**
  ```diff
  - static const String appName = 'Unclear Skies';
  + static const String appName = 'Clear Skies';
  
  - static const String welcomeTitle = 'Welcome to Unclear Skies';
  - static const String welcomeSubtitle = 'Discover the world\'s worst weather';
  + static const String welcomeTitle = 'Welcome to Clear Skies';
  + static const String welcomeSubtitle = 'Discover the world\'s weather';
  ```

- **Bug 2: `lib/core/constants/app_colors.dart`**
  ```diff
  - Color(0xFF39FF14), // Neon Green
  - Color(0xFFF0FF00), // Toxic Yellow
  - Color(0xFFFF0000), // Bright Red
  + Color(0xFF4CA1AF), // Vibrant Sky Blue
  + Color(0xFF90C8D1), // Mid Cyan
  + Color(0xFFC4E0E5), // Soft Horizon Cyan
  ```

- **Bug 3: `lib/features/weather/ui/widgets/welcome_hero_widget.dart`**
  ```diff
  - widget.onCityTapped!('Antarctica');
  + widget.onCityTapped!(city);
  ```

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
> **Need to run the demo multiple times?** 
> If you need to practice or do the demo again for a different audience, you can easily downgrade the app on the device by uninstalling it and re-running the `adb install` command with the original buggy APK (Step 1.2), then reverting your local code changes back to the buggy state.
