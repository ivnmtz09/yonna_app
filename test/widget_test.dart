import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yonna_app/main.dart';
import 'package:yonna_app/services/api_service.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await ApiService().init();

    await tester.pumpWidget(const MyApp());
    expect(find.byType(MyApp), findsOneWidget);

    // Permitir que el timer del SplashScreen concluya
    await tester.pump(const Duration(seconds: 4));
  });
}
