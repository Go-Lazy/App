import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../shared/models/how_it_works_step.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/models/vehicle_category.dart';
import '../data/home_repository.dart';
import '../data/mock_home_repository.dart';

/// The active data source for the home page. Overriding this single
/// provider (e.g. in a `ProviderScope` override) is enough to switch the
/// whole home feature from mock data to a real API-backed repository.
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return MockHomeRepository();
});

final currentLocationLabelProvider = FutureProvider<String>((ref) {
  return ref.watch(homeRepositoryProvider).getCurrentLocationLabel();
});

final vehicleCategoriesProvider = FutureProvider<List<VehicleCategory>>((ref) {
  return ref.watch(homeRepositoryProvider).getVehicleCategories();
});

final nearbyVehiclesProvider = FutureProvider<List<Vehicle>>((ref) {
  return ref.watch(homeRepositoryProvider).getNearbyVehicles();
});

final howItWorksStepsProvider = FutureProvider<List<HowItWorksStep>>((ref) {
  return ref.watch(homeRepositoryProvider).getHowItWorksSteps();
});

/// Index of the vehicle category currently highlighted in the filter row.
final selectedCategoryIndexProvider = StateProvider<int>((ref) => 0);

/// Index of the active bottom navigation tab on the home shell.
final selectedNavTabProvider = StateProvider<int>((ref) => 0);
