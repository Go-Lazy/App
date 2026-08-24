import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../shared/enums/vehicle_type.dart';
import '../../../shared/models/vehicle.dart';

/// A lightweight mock map preview showing nearby vehicle pins. Phase 1 uses
/// static local positioning instead of a real maps SDK; this widget is the
/// seam where live map/location data will plug in during a later phase.
class NearbyMapPreview extends StatelessWidget {
  const NearbyMapPreview({
    super.key,
    required this.featuredVehicle,
    required this.onViewAllVehicles,
  });

  final Vehicle? featuredVehicle;
  final VoidCallback onViewAllVehicles;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 260,
        color: AppColors.surfaceMuted,
        child: Stack(
          children: [
            const _MapPin(alignment: Alignment(-0.65, -0.55), type: VehicleType.twoWheeler),
            const _MapPin(alignment: Alignment(-0.85, 0.15), type: VehicleType.car),
            const _MapPin(alignment: Alignment(0.35, 0.35), type: VehicleType.twoWheeler),
            const _MapPin(alignment: Alignment(0.75, -0.15), type: VehicleType.car),
            const Align(
              child: _CurrentLocationDot(),
            ),
            if (featuredVehicle != null)
              Positioned(
                top: 16,
                right: 16,
                child: _FeaturedVehicleCard(vehicle: featuredVehicle!),
              ),
            Positioned(
              left: 16,
              bottom: 16,
              child: _ViewAllVehiclesPill(onTap: onViewAllVehicles),
            ),
            Positioned(
              right: 16,
              bottom: 16,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.my_location,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({required this.alignment, required this.type});

  final Alignment alignment;
  final VehicleType type;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
            ),
          ],
        ),
        child: Icon(type.icon, size: 16, color: AppColors.primary),
      ),
    );
  }
}

class _CurrentLocationDot extends StatelessWidget {
  const _CurrentLocationDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.blue.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 4),
        ],
      ),
    );
  }
}

class _FeaturedVehicleCard extends StatelessWidget {
  const _FeaturedVehicleCard({required this.vehicle});

  final Vehicle vehicle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: vehicle.thumbnailColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(vehicle.type.icon, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  vehicle.distanceLabel,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                ),
                Text(
                  '₹${vehicle.pricePerHour}/hr',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewAllVehiclesPill extends StatelessWidget {
  const _ViewAllVehiclesPill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 6),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'View all vehicles',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            SizedBox(width: 4),
            Icon(Icons.chevron_right, size: 16),
          ],
        ),
      ),
    );
  }
}
