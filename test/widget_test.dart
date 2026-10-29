import 'package:flutter_test/flutter_test.dart';
import 'package:demo_presensi_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp(isLoggedIn: false));
    expect(find.text('SiAbsen Mobile'), findsOneWidget);
  });
}
