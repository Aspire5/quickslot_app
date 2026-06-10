import 'package:flutter_test/flutter_test.dart';
import 'package:quickslot_app/main.dart';
import 'package:quickslot_app/data/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App compile and smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await StorageService.instance.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
    
    // Check that MyApp is present in the widget tree.
    expect(find.byType(MyApp), findsOneWidget);
  });
}
