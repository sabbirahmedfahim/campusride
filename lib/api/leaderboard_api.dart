import 'package:supabase_flutter/supabase_flutter.dart';

class LeaderboardEntry {
  final String userId;
  final String fullName;
  final int totalScore;
  final int rank;

  LeaderboardEntry({
    required this.userId,
    required this.fullName,
    required this.totalScore,
    required this.rank,
  });
}

class LeaderboardApi {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid => _client.auth.currentUser!.id;

  Future<List<LeaderboardEntry>> fetchTop50() async {
    final rows = await _client
        .from('users')
        .select('id, full_name, total_score, score_achieved_at')
        .gte('rides_completed', 1)
        .order('total_score', ascending: false)
        .order('score_achieved_at', ascending: true)
        .limit(50);

    final list = rows as List;
    return List.generate(list.length, (i) {
      final r = list[i];
      return LeaderboardEntry(
        userId: r['id'] as String,
        fullName: r['full_name'] as String,
        totalScore: r['total_score'] as int,
        rank: i + 1,
      );
    });
  }

  Future<LeaderboardEntry?> fetchMyRank() async {
    final rows = await _client
        .from('users')
        .select('id, full_name, total_score, rides_completed, score_achieved_at')
        .gte('rides_completed', 1)
        .order('total_score', ascending: false)
        .order('score_achieved_at', ascending: true);

    final list = rows as List;
    for (int i = 0; i < list.length; i++) {
      if (list[i]['id'] == _uid) {
        return LeaderboardEntry(
          userId: _uid,
          fullName: list[i]['full_name'] as String,
          totalScore: list[i]['total_score'] as int,
          rank: i + 1,
        );
      }
    }
    return null;
  }
}