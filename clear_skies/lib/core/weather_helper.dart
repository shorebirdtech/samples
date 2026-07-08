import 'package:clear_skies/core/core.dart';

class WeatherHelper {
  static String getWeatherIcon(int code) {
    if (code == 0) return '☀️'; // Clear sky
    if (code == 1 || code == 2 || code == 3) {
      return '🌤️'; // Mainly clear, partly cloudy, and overcast
    }
    if (code >= 45 && code <= 48) return '🌁'; // Fog
    if (code >= 51 && code <= 55) return '🌧️'; // Drizzle
    if (code >= 61 && code <= 65) return '🌧️'; // Rain
    if (code >= 71 && code <= 77) return '❄️'; // Snow
    if (code >= 80 && code <= 82) return '🌦️'; // Rain showers
    if (code >= 95 && code <= 99) return '⛈️'; // Thunderstorm
    return '🌈'; // Default
  }

  static String getWeatherDescription(int code) {
    if (code == 0) return AppStrings.weatherClearSky;
    if (code == 1 || code == 2 || code == 3) return AppStrings.weatherCloudy;
    if (code >= 45 && code <= 48) return AppStrings.weatherFoggy;
    if (code >= 51 && code <= 55) return AppStrings.weatherDrizzle;
    if (code >= 61 && code <= 65) return AppStrings.weatherRain;
    if (code >= 71 && code <= 77) return AppStrings.weatherSnow;
    if (code >= 80 && code <= 82) return AppStrings.weatherShowers;
    if (code >= 95 && code <= 99) return AppStrings.weatherThunderstorm;
    return AppStrings.errorUnknown;
  }

  static String getWeatherSuggestion(int code, double temperature) {
    if (temperature > 35) return AppStrings.suggestionHot;
    if (temperature < 5) return AppStrings.suggestionCold;

    if (code == 0) return AppStrings.suggestionClear;
    if (code == 1 || code == 2 || code == 3) return AppStrings.suggestionCloudy;
    if (code >= 45 && code <= 48) return AppStrings.suggestionFoggy;
    if (code >= 51 && code <= 65 || code >= 80 && code <= 82) {
      return AppStrings.suggestionRain;
    }
    if (code >= 71 && code <= 77) return AppStrings.suggestionSnow;
    if (code >= 95 && code <= 99) return AppStrings.suggestionThunderstorm;

    return AppStrings.suggestionDefault;
  }
}
