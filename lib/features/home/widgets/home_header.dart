import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/home_providers.dart';

/// Top branding + location + profile row shown at the top of Home,
/// matching the GoLazy brand header from the official reference design.
class HomeHeader extends ConsumerWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationAsync = ref.watch(currentLocationLabelProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(AppAssets.logo, height: 48, fit: BoxFit.contain),
        const Spacer(),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 18,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 2),
              Flexible(
                child: Text(
                  locationAsync.value ?? '',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down,
                size: 18,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => context.push(AppRoutes.profile),
          child: const Padding(
            padding: EdgeInsets.all(2),
            child: Icon(Icons.person_outline, color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
