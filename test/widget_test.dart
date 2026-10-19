import 'package:flutter_test/flutter_test.dart';
import 'package:neospend/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const NeoSpendApp());
    await tester.pump(const Duration(seconds: 3));

    // Verify that the NeoSpendApp widget is present.
    expect(find.byType(NeoSpendApp), findsOneWidget);
  });
}