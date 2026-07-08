import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundDay = Color(0xFFE0F7FA);
  static const Color backgroundNight = Color(0xFF102A43);
  static const Color textDay = Color(0xFF333333);
  static const Color textNight = Color(0xFFF0F4F8);
  static const Color cardDay = Color(0x60FFFFFF); // More transparent
  static const Color cardNight = Color(0x30000000);

  // Immersive Gradients
  static const List<Color> dayGradient = [
    Color(0xFF4CA1AF), // Vibrant Sky Blue
    Color(0xFF90C8D1), // Mid Cyan
    Color(0xFFC4E0E5), // Soft Horizon Cyan
  ];

  static const List<Color> nightGradient = [
    Color(0xFF0F2027), // Deep Space Blue
    Color(0xFF203A43), // Midnight Indigo
    Color(0xFF2C5364), // Dark Teal
  ];
}
