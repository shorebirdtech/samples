import 'package:flame/flame.dart';
import 'package:flutter_test/flutter_test.dart';

/// The skyline sprites are the first bundled assets this game has ever used,
/// so prove the declared asset path actually resolves under flutter_test
/// before any component depends on it during onLoad.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('building sprites load from the asset bundle', (tester) async {
    await tester.runAsync(() async {
      final image = await Flame.images.load('skyscraper_01.png');
      expect(image.width, greaterThan(0));
      expect(image.height, greaterThan(0));
    });
  });
}
