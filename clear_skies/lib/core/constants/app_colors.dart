import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundDay = Color(0xFFE0F7FA);
  static const Color backgroundNight = Color(0xFF102A43);
  static const Color textDay = Color(0xFF333333);
  static const Color textNight = Color(0xFFF0F4F8);
  static const Color cardDay = Color(0x60FFFFFF); // More transparent
  static const Color cardNight = Color(0x30000000);

  // Immersive Gradients
  // TODO(Demo): Revert this ugly toxic gradient back to sky blues during live patch!
  static const List<Color> dayGradient = [
    Color(0xFF39FF14), // Neon Green
    Color(0xFFF0FF00), // Toxic Yellow
    Color(0xFFFF0000), // Bright Red
  ];

  static const List<Color> nightGradient = [
    Color(0xFF0F2027), // Deep Space Blue
    Color(0xFF203A43), // Midnight Indigo
    Color(0xFF2C5364), // Dark Teal
  ];
}
