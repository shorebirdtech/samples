import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clear_skies/data/models/models.dart';
import 'package:clear_skies/core/core.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherRepository {
  final http.Client httpClient;

  WeatherRepository({http.Client? httpClient})
    : httpClient = httpClient ?? http.Client();

  Future<Weather> getWeather(String city) async {
    final geoUrl = Uri.parse(AppStrings.geoUrl(city));
    final geoRes = await httpClient.get(geoUrl);

    if (geoRes.statusCode != 200) {
      throw Exception(AppStrings.errorLocationFetch);
    }

    final geoJson = jsonDecode(geoRes.body);
    if (!geoJson.containsKey('results') || geoJson['results'].isEmpty) {
      throw Exception(AppStrings.errorCityNotFound);
    }

    final result = geoJson['results'][0];
    final lat = result['latitude'];
    final lon = result['longitude'];
    final name = result['name'];

    return getWeatherByCoordinates(lat, lon, name);
  }

  Future<Weather> getWeatherByCoordinates(
    double lat,
    double lon,
    String cityName,
  ) async {
    final weatherUrl = Uri.parse(AppStrings.weatherUrl(lat, lon));
    final weatherRes = await httpClient.get(weatherUrl);

    if (weatherRes.statusCode != 200) {
      throw Exception(AppStrings.errorWeatherFetch);
    }

    final weatherJson = jsonDecode(weatherRes.body);
    return Weather.fromJson(cityName, weatherJson);
  }

  Future<List<CitySuggestion>> searchCities(String query) async {
    if (query.trim().isEmpty) return [];

    final geoUrl = Uri.parse(AppStrings.geoSearchUrl(query.trim()));
    final geoRes = await httpClient.get(geoUrl);

    if (geoRes.statusCode != 200) return [];

    final geoJson = jsonDecode(geoRes.body);
    if (!geoJson.containsKey('results') || geoJson['results'].isEmpty) {
      return [];
    }

    final results = geoJson['results'] as List;
    final List<CitySuggestion> suggestions = [];
    final Set<String> uniqueDisplayNames = {};

    for (var result in results) {
      final suggestion = CitySuggestion(
        name: result['name'] as String,
        admin1: result['admin1'] as String?,
        country: result['country'] as String?,
        latitude: (result['latitude'] as num).toDouble(),
        longitude: (result['longitude'] as num).toDouble(),
      );

      final display = suggestion.displayName;
      if (!uniqueDisplayNames.contains(display)) {
        uniqueDisplayNames.add(display);
        suggestions.add(suggestion);
      }
    }

    return suggestions;
  }

  Future<List<String>> getFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesList = prefs.getStringList('favorite_cities');
      return favoritesList?.toList() ?? [];
    } catch (_) {
      return [];
    }
  }

  Future<void> saveFavorites(List<String> favorites) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('favorite_cities', favorites);
    } catch (_) {}
  }
}
