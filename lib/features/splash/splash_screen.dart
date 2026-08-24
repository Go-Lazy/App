import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/constants/app_assets.dart';
import '../update/providers/update_providers.dart';

/// First screen shown on app launch. Displays the official GoLazy
/// splashscreen artwork for exactly two seconds before navigating to Home.
///
/// Also kicks off the update check immediately (in parallel with the
/// countdown, never delaying it) so a result is ready as soon as Home can
/// show it.
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  static const Duration _splashDuration = Duration(seconds: 2);

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: a slow or failed check must never delay the splash
    // or the navigation to Home.
    ref.read(appUpdateCheckProvider.future).ignore();

    _navigationTimer = Timer(_splashDuration, () {
      if (mounted) context.go(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox.expand(
        child: Image(
          image: AssetImage(AppAssets.splashScreen),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
