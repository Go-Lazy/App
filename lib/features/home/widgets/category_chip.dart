import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/enums/vehicle_type.dart';
import '../../../shared/models/vehicle_category.dart';

/// A single vehicle-category filter tile (icon, label, starting price).
class CategoryChip extends StatelessWidget {
  const CategoryChip({
    super.key,
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final VehicleCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isMore = category.priceFromPerHour == 0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              category.type.icon,
              size: 22,
              color: category.type == VehicleType.electric
                  ? AppColors.success
                  : AppColors.textPrimary,
            ),
            const SizedBox(height: 6),
            Text(
              category.type.label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              isMore ? 'All Types' : 'From ₹${category.priceFromPerHour}/hr',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
