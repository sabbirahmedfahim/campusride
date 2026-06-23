import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../entities/conversation.dart';

class ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final VoidCallback onTap;

  const ConversationTile({super.key, required this.conversation, required this.onTap});

  String _timeLabel(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return DateFormat('h:mm a').format(dt);
    }
    return DateFormat('d MMM').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          (conversation.otherUserName ?? '?').isNotEmpty
              ? conversation.otherUserName![0].toUpperCase()
              : '?',
        ),
      ),
      title: Text(conversation.otherUserName ?? 'Unknown User'),
      subtitle: Text(
        conversation.lastMessage ?? 'Say hello 👋',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        _timeLabel(conversation.lastMessageAt),
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      onTap: onTap,
    );
  }
}