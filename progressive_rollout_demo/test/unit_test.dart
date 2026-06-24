import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progressive_rollout_demo/main.dart';

void main() {
  test('getGroupNumber returns cached value if available', () async {
    SharedPreferences.setMockInitialValues({'groupNumber': 42});
    final groupNumber = await getGroupNumber();
    expect(groupNumber, 42);
  });

  test('getGroupNumber generates value if not available', () async {
    SharedPreferences.setMockInitialValues({});
    final groupNumber = await getGroupNumber();
    expect(groupNumber, isNotNull);
    expect(groupNumber >= 1 && groupNumber <= 100, isTrue);
  });
}
