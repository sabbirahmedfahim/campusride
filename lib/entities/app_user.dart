class AppUser {
  final String id;
  final String fullName;
  final String phone;
  final String gender;
  final String email;
  final DateTime? lastRideActionAt;
  final int totalScore;
  final int ridesCompleted;
  final DateTime? scoreAchievedAt;
  final DateTime createdAt;
  final bool isAdmin;
  final bool isBanned;

  AppUser({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.gender,
    required this.email,
    required this.lastRideActionAt,
    required this.totalScore,
    required this.ridesCompleted,
    required this.scoreAchievedAt,
    required this.createdAt,
    this.isAdmin = false,
    this.isBanned = false,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      id: map['id'] as String,
      fullName: map['full_name'] as String,
      phone: map['phone'] as String,
      gender: map['gender'] as String,
      email: map['email'] as String,
      lastRideActionAt: map['last_ride_action_at'] == null
          ? null
          : DateTime.parse(map['last_ride_action_at'] as String),
      totalScore: map['total_score'] as int,
      ridesCompleted: map['rides_completed'] as int,
      scoreAchievedAt: map['score_achieved_at'] == null
          ? null
          : DateTime.parse(map['score_achieved_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      isAdmin: map['is_admin'] as bool? ?? false,
      isBanned: map['is_banned'] as bool? ?? false,
    );
  }

  DateTime? cooldownEndsAt() {
    if (lastRideActionAt == null) return null;
    final end = lastRideActionAt!.add(const Duration(minutes: 30));
    if (DateTime.now().isAfter(end)) return null;
    return end;
  }
}