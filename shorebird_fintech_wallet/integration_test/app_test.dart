import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shorebird_fintech_wallet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('app launches successfully', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    
    // We just verify that it doesn't crash on launch
    expect(find.text('0'), findsNothing); // Dummy check
  });
}
