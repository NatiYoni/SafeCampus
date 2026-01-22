import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

class Zone extends Equatable {
  final String id;
  final String name;
  final String description;
  final List<LatLng> coordinates; // Polygon
  final String riskLevel; // 'High', 'Medium', 'Safe'
  final String message;

  const Zone({
    required this.id,
    required this.name,
    required this.description,
    required this.coordinates,
    required this.riskLevel,
    required this.message,
  });

  @override
  List<Object?> get props => [id, name, coordinates, riskLevel];
}
