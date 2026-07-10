# ⛅️ Clear Skies

A beautifully designed, premium weather application built with Flutter. 

Clear Skies goes beyond standard weather apps by offering an immersive, dynamic, and glassmorphic UI. It focuses on providing a frictionless user experience with automatic location detection and gorgeous visual aesthetics.

## ✨ Features

- **Immersive Glassmorphic UI**: Experience a sleek, modern interface with frosted glass components (`BackdropFilter`) and refined typography (`GoogleFonts`).
- **Dynamic Environments**: The app background is a rich, animated `LinearGradient` that automatically shifts between a vibrant daylight sky and a deep midnight blue depending on the weather's time of day.
- **Zero-Click Onboarding**: Powered by `geolocator` and `geocoding`, the app automatically detects your location and reverse-geocodes your coordinates to instantly display your local weather upon launch.
- **"Popular Destinations" Quick-Select**: If location is disabled, you are presented with elegant chips for popular global cities (Tokyo, London, New York, etc.) for instant 1-tap weather forecasts.
- **Persistent Favorites**: Save your most-visited cities to a horizontal scrollable list. Your favorites are stored locally using `shared_preferences` so they're always there when you return.
- **Responsive & Performant**: Highly optimized widget tree utilizing `BlocBuilder` and `ValueListenableBuilder` to ensure minimal rebuilds and buttery-smooth 60+ FPS performance.

## 🛠 Tech Stack & Dependencies

- **State Management**: [flutter_bloc](https://pub.dev/packages/flutter_bloc) for highly scalable, predictable, and robust state management.
- **Location Services**: 
  - [geolocator](https://pub.dev/packages/geolocator) for highly accurate native GPS coordinates.
  - [geocoding](https://pub.dev/packages/geocoding) for resolving coordinates into human-readable city names (Reverse Geocoding).
- **Data Persistence**: [shared_preferences](https://pub.dev/packages/shared_preferences) for local key-value storage.
- **Networking**: [http](https://pub.dev/packages/http) for fetching live data from the free, open-source [Open-Meteo API](https://open-meteo.com/).
- **Design & Assets**: 
  - [google_fonts](https://pub.dev/packages/google_fonts) (using *Outfit* and *Inter* fonts).

## 🚀 Getting Started

1. Ensure you have the [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
2. Clone this repository.
3. Fetch the required dependencies:
   ```bash
   flutter pub get
   ```
4. **Important**: Because this app uses native plugins (`geolocator`, `geocoding`, `shared_preferences`), you must perform a full build if running for the first time:
   - For iOS, run `cd ios && pod install` if your IDE doesn't do it automatically.
5. Run the app:
   ```bash
   flutter run
   ```

## 🧪 Testing

This project includes a robust suite of over 70+ automated widget and unit tests ensuring stability across the bloc layer and the UI.
To run the tests:
```bash
flutter test
```
