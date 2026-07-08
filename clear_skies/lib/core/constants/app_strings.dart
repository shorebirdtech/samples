class AppStrings {
  static const String appName = 'Clear Skies';
  static const String searchHint = 'Search city...';

  static const String welcomeTitle = 'Welcome to Clear Skies';
  static const String welcomeSubtitle = 'Discover the world\'s weather';

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

  static const String suggestionClear =
      'Perfect weather! Grab your sunglasses.';
  static const String suggestionCloudy =
      'A bit gloomy, but a great day for a walk.';
  static const String suggestionRain =
      'Don\'t forget your umbrella! It\'s raining.';
  static const String suggestionSnow = 'Bundle up! It\'s snowing outside.';
  static const String suggestionThunderstorm =
      'Stay indoors! Thunderstorms ahead.';
  static const String suggestionHot =
      'It\'s hot! Stay hydrated and wear sunscreen.';
  static const String suggestionCold = 'It\'s freezing! Wear a heavy coat.';
  static const String suggestionFoggy = 'Drive safely! Visibility is low.';
  static const String suggestionDefault = 'Have a great day ahead!';

  static const String smokeTestName = 'App smoke test';
  static const String loadingMessage = 'Looking up at the sky...';

  static String geoUrl(String city) =>
      'https://geocoding-api.open-meteo.com/v1/search?name=$city&count=1';
  static String geoSearchUrl(String query) =>
      'https://geocoding-api.open-meteo.com/v1/search?name=$query&count=5';
  static String weatherUrl(double lat, double lon) =>
      'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,apparent_temperature,is_day,weather_code,wind_speed_10m&daily=weather_code,temperature_2m_max,temperature_2m_min&timezone=auto';
}
