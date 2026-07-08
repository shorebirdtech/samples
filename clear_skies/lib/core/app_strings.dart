class AppStrings {
  static const String appName = 'Clear Skies';
  static const String searchHint = 'Search city...';
  static const String initialSearchPrompt = 'Search for a city';

  static const String errorLocationFetch = 'Failed to fetch location data';
  static const String errorCityNotFound = 'City not found';
  static const String errorWeatherFetch = 'Failed to fetch weather data';
  static const String errorUnknown = 'Unknown';

  static const String weatherClearSky = 'Clear sky';
  static const String weatherCloudy = 'Cloudy';
  static const String weatherFoggy = 'Foggy';
  static const String weatherDrizzle = 'Drizzle';
  static const String weatherRain = 'Rain';
  static const String weatherSnow = 'Snow';
  static const String weatherShowers = 'Showers';
  static const String weatherThunderstorm = 'Thunderstorm';

  static const String smokeTestName = 'App smoke test';
  static const String loadingMessage = 'Looking up at the sky...';

  static String geoUrl(String city) =>
      'https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1';
  static String geoSearchUrl(String query) =>
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5';
  static String weatherUrl(double lat, double lon) =>
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current_weather=true';
}
