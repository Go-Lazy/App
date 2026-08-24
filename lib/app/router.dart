import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/widgets/coming_soon_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';

/// Named route paths for the app. Centralizing these avoids magic strings
/// scattered across screens when navigation grows in later phases.
abstract class AppRoutes {
  const AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String chat = '/chat';
  static const String bookings = '/bookings';
  static const String wallet = '/wallet';
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
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ComingSoonScreen(
          title: 'Profile',
          icon: Icons.person_outline,
          message: 'Account details, KYC and settings will appear here.',
        ),
      ),
      GoRoute(
        path: AppRoutes.chat,
        builder: (context, state) => const ComingSoonScreen(
          title: 'Chat',
          icon: Icons.chat_bubble_outline,
          message: 'Message owners and renters directly from here.',
        ),
      ),
      GoRoute(
        path: AppRoutes.bookings,
        builder: (context, state) => const ComingSoonScreen(
          title: 'Bookings',
          icon: Icons.calendar_today_outlined,
          message: 'Your upcoming and past rentals will appear here.',
        ),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (context, state) => const ComingSoonScreen(
          title: 'Wallet',
          icon: Icons.account_balance_wallet_outlined,
          message: 'Payments, refunds and saved methods will appear here.',
        ),
      ),
    ],
  );
}
