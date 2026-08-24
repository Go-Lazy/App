import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Placeholder Profile destination. Reachable from the home header's
/// profile icon; full profile functionality lands in a later phase.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: AppColors.primarySurface,
              child: Icon(
                Icons.person_outline,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Your profile is coming soon',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Account details, KYC and settings will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
