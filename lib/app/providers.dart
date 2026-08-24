import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'router.dart';

/// App-wide GoRouter instance, exposed as a provider so future auth state
/// (e.g. redirecting signed-out users to a login screen) can drive routing
/// decisions via `ref` without restructuring the app shell.
final appRouterProvider = Provider<GoRouter>((ref) => buildAppRouter());
