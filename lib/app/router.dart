import 'package:go_router/go_router.dart';

import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';

/// Named route paths for the app. Centralizing these avoids magic strings
/// scattered across screens when navigation grows in later phases.
abstract class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
}

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
}
