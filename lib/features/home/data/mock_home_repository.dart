import 'package:flutter/material.dart';

import '../../../shared/models/how_it_works_step.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/models/vehicle_category.dart';
import '../../../shared/enums/vehicle_type.dart';
import 'home_repository.dart';

/// Phase 1 implementation of [HomeRepository] backed by local mock data.
/// Swap the provider override in `home_providers.dart` to point at a real
/// API-backed repository once the backend is available.
class MockHomeRepository implements HomeRepository {
  @override
  Future<String> getCurrentLocationLabel() async => 'Imphal, Manipur';

  @override
  Future<List<VehicleCategory>> getVehicleCategories() async => const [
        VehicleCategory(type: VehicleType.twoWheeler, priceFromPerHour: 80),
        VehicleCategory(type: VehicleType.car, priceFromPerHour: 250),
        VehicleCategory(type: VehicleType.suv, priceFromPerHour: 350),
        VehicleCategory(type: VehicleType.electric, priceFromPerHour: 70),
        VehicleCategory(type: VehicleType.more, priceFromPerHour: 0),
      ];

  @override
  Future<List<Vehicle>> getNearbyVehicles() async => const [
        Vehicle(
          id: 'v1',
          name: 'Honda Activa 6G',
          type: VehicleType.twoWheeler,
          distanceInMeters: 180,
          pricePerHour: 80,
          rating: 4.8,
          ratingCount: 120,
          thumbnailColor: Color(0xFFFFE8D6),
        ),
        Vehicle(
          id: 'v2',
          name: 'Maruti Swift Dzire',
          type: VehicleType.car,
          distanceInMeters: 350,
          pricePerHour: 250,
          rating: 4.7,
          ratingCount: 98,
          thumbnailColor: Color(0xFFFCE1DE),
        ),
        Vehicle(
          id: 'v3',
          name: 'Hyundai Creta',
          type: VehicleType.suv,
          distanceInMeters: 600,
          pricePerHour: 350,
          rating: 4.8,
          ratingCount: 76,
          thumbnailColor: Color(0xFFE9EBEF),
        ),
      ];

  @override
  Future<List<HowItWorksStep>> getHowItWorksSteps() async => const [
        HowItWorksStep(
          stepNumber: 1,
          icon: Icons.location_on_outlined,
          title: 'Find',
          description: 'Search vehicles\nnear you',
        ),
        HowItWorksStep(
          stepNumber: 2,
          icon: Icons.assignment_outlined,
          title: 'Choose',
          description: 'Select vehicle,\ntime & book',
        ),
        HowItWorksStep(
          stepNumber: 3,
          icon: Icons.verified_outlined,
          title: 'Pick Up',
          description: 'Pick up or get\ndelivery',
        ),
        HowItWorksStep(
          stepNumber: 4,
          icon: Icons.sports_motorsports_outlined,
          title: 'Enjoy',
          description: 'Travel safely\nand enjoy',
        ),
        HowItWorksStep(
          stepNumber: 5,
          icon: Icons.check_circle_outline,
          title: 'Return',
          description: 'Return & complete\nthe trip',
        ),
      ];
}
