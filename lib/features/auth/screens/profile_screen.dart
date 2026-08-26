import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/auth_providers.dart';
import '../providers/auth_state.dart';

/// Profile tab: prompts sign-in/sign-up when logged out, otherwise shows the
/// account summary and a logout action. This is GoLazy's only entry point
/// into the auth flow today (tapped from the profile icon in `HomeHeader`).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: switch (authState.status) {
          AuthStatus.unknown => const Center(child: CircularProgressIndicator()),
          AuthStatus.unauthenticated => const _LoggedOutView(),
          AuthStatus.authenticated => _LoggedInView(user: authState),
        },
      ),
    );
  }
}

class _LoggedOutView extends StatelessWidget {
  const _LoggedOutView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primarySurface,
              child: const Icon(Icons.person_outline, size: 36, color: AppColors.primary),
            ),
            const SizedBox(height: 16),
            const Text(
              "You're not logged in",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 4),
            const Text(
              'Log in or create an account to book vehicles and track your rentals.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => context.push(AppRoutes.login),
                child: const Text('Log in'),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.push(AppRoutes.register),
                child: const Text('Create account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoggedInView extends ConsumerWidget {
  const _LoggedInView({required this.user});

  final AuthState user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = user.user!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: AppColors.primarySurface,
          child: Text(
            (account.name?.isNotEmpty ?? false)
                ? account.name![0].toUpperCase()
                : account.phone.substring(account.phone.length - 1),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          account.name?.isNotEmpty == true ? account.name! : 'GoLazy user',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 2),
        Text(account.phone, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 20),
        _InfoTile(
          icon: Icons.verified_user_outlined,
          label: 'Renter verification',
          value: account.renterVerificationStatus ?? 'NOT_STARTED',
        ),
        _InfoTile(
          icon: Icons.directions_car_outlined,
          label: 'Owner mode',
          value: account.ownerEnabled ? 'Enabled' : 'Not enabled',
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => ref.read(authControllerProvider.notifier).logout(),
            child: const Text('Log out'),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}
