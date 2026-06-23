class NotificationItem {
  final String id;
  final String userId;
  final String rideId;
  final String type;
  final bool isRead;
  final DateTime createdAt;

  final String? rideDirection;
  final String? riderName;

  NotificationItem({
    required this.id,
    required this.userId,
    required this.rideId,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.rideDirection,
    this.riderName,
  });

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    final ride = map['rides'];
    return NotificationItem(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      rideId: map['ride_id'] as String,
      type: map['type'] as String,
      isRead: map['is_read'] as bool,
      createdAt: DateTime.parse(map['created_at'] as String),
      rideDirection: ride != null ? ride['direction'] as String? : null,
      riderName: ride != null && ride['users'] != null
          ? ride['users']['full_name'] as String?
          : null,
    );
  }
}