import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// A section title with an optional trailing "View all" action, reused
/// across home page sections (e.g. "Vehicles Near You").
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (onViewAll != null)
          GestureDetector(
            onTap: onViewAll,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'View all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Icon(Icons.chevron_right, color: AppColors.primary, size: 18),
              ],
            ),
          ),
      ],
    );
  }
}
