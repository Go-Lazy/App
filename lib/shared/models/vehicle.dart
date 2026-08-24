import '../enums/vehicle_type.dart';

/// A vehicle listing shown on the home page. Backed today by
/// [MockHomeRepository]; later replaced by data fetched from the GoLazy API
/// without changing the presentation layer.
class Vehicle {
  const Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.distanceInMeters,
    required this.pricePerHour,
    required this.rating,
    required this.ratingCount,
    required this.imageAsset,
  });

  final String id;
  final String name;
  final VehicleType type;
  final int distanceInMeters;
  final int pricePerHour;
  final double rating;
  final int ratingCount;
  final String imageAsset;

  String get distanceLabel => distanceInMeters < 1000
      ? '$distanceInMeters m away'
      : '${(distanceInMeters / 1000).toStringAsFixed(1)} km away';
}
