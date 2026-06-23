class Conversation {
  final String id;
  final String userA;
  final String userB;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final DateTime createdAt;
  final DateTime? lastReadAtA;
  final DateTime? lastReadAtB;

  final String? otherUserName;

  Conversation({
    required this.id,
    required this.userA,
    required this.userB,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.createdAt,
    required this.lastReadAtA,
    required this.lastReadAtB,
    this.otherUserName,
  });

  String otherUserId(String myId) => userA == myId ? userB : userA;

  bool isUnreadFor(String myId) {
    if (lastMessageAt == null) return false;
    final myLastRead = myId == userA ? lastReadAtA : lastReadAtB;
    if (myLastRead == null) return true;
    return lastMessageAt!.isAfter(myLastRead);
  }

  factory Conversation.fromMap(Map<String, dynamic> map, {String? myId}) {
    String? otherName;
    if (myId != null) {
      final isUserA = map['user_a'] == myId;
      final otherProfile = isUserA ? map['user_b_profile'] : map['user_a_profile'];
      if (otherProfile != null) {
        otherName = otherProfile['full_name'] as String?;
      }
    }
    return Conversation(
      id: map['id'] as String,
      userA: map['user_a'] as String,
      userB: map['user_b'] as String,
      lastMessage: map['last_message'] as String?,
      lastMessageAt: map['last_message_at'] == null
          ? null
          : DateTime.parse(map['last_message_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      lastReadAtA: map['last_read_at_a'] == null
          ? null
          : DateTime.parse(map['last_read_at_a'] as String),
      lastReadAtB: map['last_read_at_b'] == null
          ? null
          : DateTime.parse(map['last_read_at_b'] as String),
      otherUserName: otherName,
    );
  }
}