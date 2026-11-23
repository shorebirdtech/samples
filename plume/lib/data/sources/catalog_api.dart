import 'dart:convert';

import 'package:flutter/services.dart';

/// Thrown when the (simulated) backend can't be reached.
class NetworkException implements Exception {
  const NetworkException([this.message = 'Network request failed']);

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

/// Simulates the store's REST API with bundled JSON, so demos work without a
/// network connection. Responses arrive after [latency] to exercise loading
/// states the way a real backend would.
class CatalogApi {
  CatalogApi({
    AssetBundle? bundle,
    this.latency = const Duration(milliseconds: 450),
  }) : _bundle = bundle ?? rootBundle;

  static const _assetPath = 'assets/data/catalog.json';

  final AssetBundle _bundle;
  final Duration latency;

  Map<String, dynamic>? _cache;

  /// When set, the next request fails once. Useful to demo error states.
  bool failNextRequest = false;

  Future<List<Map<String, dynamic>>> get(String resource) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (failNextRequest) {
      failNextRequest = false;
      throw const NetworkException();
    }
    // The decoded JSON is cached here, so skip the bundle's own cache.
    final data = _cache ??= jsonDecode(
      await _bundle.loadString(_assetPath, cache: false),
    ) as Map<String, dynamic>;
    final list = data[resource] as List<dynamic>? ?? const [];
    return list.cast<Map<String, dynamic>>();
  }
}
