import '../../../shared/models/how_it_works_step.dart';
import '../../../shared/models/vehicle.dart';
import '../../../shared/models/vehicle_category.dart';

/// Data contract for the home page. [MockHomeRepository] is the Phase 1
/// implementation; a future `ApiHomeRepository` backed by the GoLazy Fastify
/// API can implement this same interface without any change to the UI layer.
abstract class HomeRepository {
  Future<String> getCurrentLocationLabel();

  Future<List<VehicleCategory>> getVehicleCategories();

  Future<List<Vehicle>> getNearbyVehicles();

  Future<List<HowItWorksStep>> getHowItWorksSteps();
}
