class Ride {
  final String id;
  final String riderId;
  final String direction;
  final double pickupLat;
  final double pickupLng;
  final String vehicleType;
  final int? route;
  final String status;
  final DateTime createdAt;
  final DateTime? closedAt;

  final String? riderName;
  final String? riderPhone;

  Ride({
    required this.id,
    required this.riderId,
    required this.direction,
    required this.pickupLat,
    required this.pickupLng,
    required this.vehicleType,
    required this.route,
    required this.status,
    required this.createdAt,
    required this.closedAt,
    this.riderName,
    this.riderPhone,
  });

  factory Ride.fromMap(Map<String, dynamic> map) {
    return Ride(
      id: map['id'] as String,
      riderId: map['rider_id'] as String,
      direction: map['direction'] as String,
      pickupLat: (map['pickup_lat'] as num).toDouble(),
      pickupLng: (map['pickup_lng'] as num).toDouble(),
      vehicleType: map['vehicle_type'] as String,
      route: map['route'] == null ? null : map['route'] as int,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      closedAt: map['closed_at'] == null
          ? null
          : DateTime.parse(map['closed_at'] as String),
      riderName: map['users'] != null ? map['users']['full_name'] as String? : null,
      riderPhone: map['users'] != null ? map['users']['phone'] as String? : null,
    );
  }

  String get directionLabel => direction == 'from_lu' ? 'From LU' : 'To LU';

  DateTime get expiresAt => createdAt.add(const Duration(minutes: 30));
}