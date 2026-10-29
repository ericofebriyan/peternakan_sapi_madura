import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ternakpro/main.dart';
import 'package:ternakpro/screens/splash_screen.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  testWidgets('TernakProApp splash screen transition test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TernakProApp());

    // Verify SplashScreen is rendered initially
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Manajemen Kandang & Estimasi AI'), findsOneWidget);

    // Advance clock past the splash timer (2200ms) and transition duration (600ms)
    await tester.pump(const Duration(milliseconds: 3000));
  });
}
