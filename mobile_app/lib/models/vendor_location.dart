
class VendorLocation {
  final int id;
  final String vendorName;
  final double latitude;
  final double longitude;
  final String address;
  final double confidenceScore;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? scheduledStart;
  final DateTime? scheduledEnd;
  final List<String> daysOfWeek;
  final bool isCurrent;

  VendorLocation({
    required this.id,
    required this.vendorName,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.confidenceScore,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.scheduledStart,
    this.scheduledEnd,
    required this.daysOfWeek,
    required this.isCurrent,
  });

  factory VendorLocation.fromJson(Map<String, dynamic> json) {
    return VendorLocation(
      id: json['id'],
      vendorName: json['vendor_name'],
      latitude: json['point']['coordinates'][1].toDouble(),
      longitude: json['point']['coordinates'][0].toDouble(),
      address: json['address'],
      confidenceScore: json['confidence_score'].toDouble(),
      isActive: json['is_active'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      scheduledStart: json['scheduled_start'] != null 
          ? DateTime.parse(json['scheduled_start'])
          : null,
      scheduledEnd: json['scheduled_end'] != null 
          ? DateTime.parse(json['scheduled_end'])
          : null,
      daysOfWeek: List<String>.from(json['days_of_week']),
      isCurrent: json['is_current'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendor_name': vendorName,
      'point': {
        'type': 'Point',
        'coordinates': [longitude, latitude]
      },
      'address': address,
      'is_active': isActive,
      'scheduled_start': scheduledStart?.toIso8601String(),
      'scheduled_end': scheduledEnd?.toIso8601String(),
      'days_of_week': daysOfWeek,
    };
  }
}