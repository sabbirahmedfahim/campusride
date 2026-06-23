import 'package:flutter/material.dart';
import '../api/leaderboard_api.dart';

class LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardRow({
    super.key,
    required this.entry,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isFirst = entry.rank == 1;

    if (isFirst) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
          ),
          borderRadius: BorderRadius.circular(16),
          border: isCurrentUser ? Border.all(color: Colors.black, width: 2) : null,
        ),
        child: Row(
          children: [
            const Icon(Icons.emoji_events, size: 32, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Text(
              '${entry.totalScore} pts',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text('#${entry.rank}', style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: Text(entry.fullName)),
          Text('${entry.totalScore} pts', style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}