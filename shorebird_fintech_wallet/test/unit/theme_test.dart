import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shorebird_fintech_wallet/core/app_theme.dart';

void main() {
  group('AppTheme Tests', () {
    test('AppTheme should have correct color tokens', () {
      expect(AppTheme.backgroundColor, const Color(0xFF0F172A));
      expect(AppTheme.primaryColor, const Color(0xFF1E88E5));
      expect(AppTheme.accentColor, const Color(0xFF38BDF8));
    });
  });
}
