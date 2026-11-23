import 'package:material_ui/material_ui.dart';

/// Brand colours shared by the light and dark themes: a neutral base with a
/// single cobalt accent.
abstract final class Palette {
  static const ink = Color(0xFF111111);
  static const night = Color(0xFF0E0E0E);
  static const nightRaised = Color(0xFF1A1A1A);
  static const mist = Color(0xFFF6F6F4);
  static const cloud = Color(0xFFFFFFFF);

  /// The accent. Readable on both the light and the dark background.
  static const violet = Color(0xFF3557E0);
  static const iris = Color(0xFF8C93A1);
  static const aqua = Color(0xFF6B7280);
  static const coral = Color(0xFFD64545);
  static const amber = Color(0xFFE0A526);
  static const success = Color(0xFF2E8B57);

  /// Kept as gradients so call sites stay simple; both are flat.
  static const brandGradient = LinearGradient(colors: [violet, violet]);
  static const sunsetGradient = LinearGradient(colors: [ink, ink]);

  /// Parses a `#RRGGBB` string from the catalog data.
  static Color fromHex(String hex) {
    final value = hex.replaceFirst('#', '');
    return Color(int.parse('FF$value', radix: 16));
  }
}
