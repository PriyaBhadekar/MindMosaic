// CREATE lib/data/models/geofence_model.dart
class GeofenceModel {
  final int? id;
  final double latitude;
  final double longitude;
  final double radius;
  final String? address;
  final bool active;

  GeofenceModel({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
    this.address,
    this.active = true,
  });

  factory GeofenceModel.fromJson(Map<String, dynamic> json) => GeofenceModel(
    id: json['id'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    radius: (json['radius'] as num).toDouble(),
    address: json['address'],
    active: json['active'] ?? true,
  );
}