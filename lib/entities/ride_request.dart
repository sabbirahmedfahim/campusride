class RideRequest {
  final String id;
  final String requesterId;
  final double pickupLat;
  final double pickupLng;
  final List<int> routes;
  final String direction;
  final String status;
  final DateTime createdAt;
  final DateTime? closedAt;

  final String? requesterName;

  RideRequest({
    required this.id,
    required this.requesterId,
    required this.pickupLat,
    required this.pickupLng,
    required this.routes,
    required this.direction,
    required this.status,
    required this.createdAt,
    required this.closedAt,
    this.requesterName,
  });

  factory RideRequest.fromMap(Map<String, dynamic> map) {
    return RideRequest(
      id: map['id'] as String,
      requesterId: map['requester_id'] as String,
      pickupLat: (map['pickup_lat'] as num).toDouble(),
      pickupLng: (map['pickup_lng'] as num).toDouble(),
      routes: (map['routes'] as List).cast<int>(),
      direction: map['direction'] as String,
      status: map['status'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
      closedAt: map['closed_at'] == null
          ? null
          : DateTime.parse(map['closed_at'] as String),
      requesterName: map['users'] != null
          ? map['users']['full_name'] as String?
          : null,
    );
  }

  String get routesLabel => routes.map((r) => 'Route $r').join(', ');
  String get directionLabel => direction == 'from_lu' ? 'From LU' : 'To LU';

  DateTime get expiresAt => createdAt.add(const Duration(minutes: 30));
}