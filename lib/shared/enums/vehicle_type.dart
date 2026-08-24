import 'package:flutter/material.dart';

/// Vehicle category types shown on the GoLazy home page filter row.
enum VehicleType { twoWheeler, car, suv, electric, more }

extension VehicleTypeX on VehicleType {
  String get label {
    switch (this) {
      case VehicleType.twoWheeler:
        return '2-Wheeler';
      case VehicleType.car:
        return 'Cars';
      case VehicleType.suv:
        return 'SUVs';
      case VehicleType.electric:
        return 'Electric';
      case VehicleType.more:
        return 'More';
    }
  }

  IconData get icon {
    switch (this) {
      case VehicleType.twoWheeler:
        return Icons.two_wheeler;
      case VehicleType.car:
        return Icons.directions_car;
      case VehicleType.suv:
        return Icons.airport_shuttle;
      case VehicleType.electric:
        return Icons.electric_bolt;
      case VehicleType.more:
        return Icons.grid_view_rounded;
    }
  }
}
