// Smoke test verifying the GoLazy Phase 1 splash-to-home navigation flow.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:golazy_app/app/app.dart';
import 'package:golazy_app/features/home/home_screen.dart';
import 'package:golazy_app/features/splash/splash_screen.dart';

void main() {
  testWidgets('shows splash then navigates to home after 2 seconds', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: GoLazyApp()));

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(HomeScreen), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
