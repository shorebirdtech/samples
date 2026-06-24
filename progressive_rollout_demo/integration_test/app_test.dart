import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:progressive_rollout_demo/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches successfully', (WidgetTester tester) async {
    await app.main();
    await tester.pumpAndSettle();
    expect(find.byType(app.MyApp), findsOneWidget);
  });
}
