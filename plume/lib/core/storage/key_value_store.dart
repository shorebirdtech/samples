import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper over [SharedPreferencesAsync] so repositories can be tested
/// with an in-memory store.
abstract class KeyValueStore {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);

  Future<Object?> readJson(String key) async {
    final raw = await read(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      await delete(key);
      return null;
    }
  }

  Future<void> writeJson(String key, Object? value) =>
      write(key, jsonEncode(value));
}

class SharedPreferencesStore extends KeyValueStore {
  SharedPreferencesStore([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  @override
  Future<String?> read(String key) => _preferences.getString(key);

  @override
  Future<void> write(String key, String value) =>
      _preferences.setString(key, value);

  @override
  Future<void> delete(String key) => _preferences.remove(key);
}

class InMemoryStore extends KeyValueStore {
  InMemoryStore([Map<String, String>? values]) : _values = values ?? {};

  final Map<String, String> _values;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<void> delete(String key) async => _values.remove(key);
}
