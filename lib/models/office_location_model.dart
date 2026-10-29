class PolygonCoordinate {
  final double lat;
  final double lng;

  PolygonCoordinate({required this.lat, required this.lng});

  factory PolygonCoordinate.fromJson(Map<String, dynamic> json) {
    return PolygonCoordinate(
      lat: (json['lat'] as num).toDouble(),
      lng: (json['lng'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};
}

class OfficeLocationModel {
  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final double radiusMeters;
  final List<PolygonCoordinate> polygonCoordinates;
  final bool isActive;

  OfficeLocationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    required this.polygonCoordinates,
    required this.isActive,
  });

  factory OfficeLocationModel.fromJson(Map<String, dynamic> json) {
    final polyList = json['polygon_coordinates'] as List<dynamic>? ?? [];
    return OfficeLocationModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusMeters: (json['radius_meters'] as num?)?.toDouble() ?? 100.0,
      polygonCoordinates: polyList
          .map((item) => PolygonCoordinate.fromJson(item as Map<String, dynamic>))
          .toList(),
      isActive: json['is_active'] is bool
          ? json['is_active'] as bool
          : (json['is_active'] == 1 || json['is_active'] == '1'),
    );
  }
}

