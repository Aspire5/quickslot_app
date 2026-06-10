import 'package:flutter_test/flutter_test.dart';
import 'package:quickslot_app/main.dart';

void main() {
  testWidgets('App compile and smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Check that MyApp is present in the widget tree.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
