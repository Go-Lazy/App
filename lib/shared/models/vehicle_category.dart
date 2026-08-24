import '../enums/vehicle_type.dart';

/// A vehicle category filter shown on the home page (e.g. "2-Wheeler",
/// "Cars"). Backed today by [MockHomeRepository]; later replaced by data
/// fetched from the GoLazy API without changing the presentation layer.
class VehicleCategory {
  const VehicleCategory({
    required this.type,
    required this.priceFromPerHour,
  });

  final VehicleType type;
  final int priceFromPerHour;
}
