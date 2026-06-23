import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/conversation.dart';
import '../entities/chat_message.dart';

class ChatApi {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid => _client.auth.currentUser!.id;

  (String, String) _orderedPair(String otherUserId) {
    return _uid.compareTo(otherUserId) < 0 ? (_uid, otherUserId) : (otherUserId, _uid);
  }

  Future<Conversation> getOrCreateConversation(String otherUserId) async {
    final (a, b) = _orderedPair(otherUserId);

    final existing = await _client
        .from('conversations')
        .select()
        .eq('user_a', a)
        .eq('user_b', b)
        .maybeSingle();

    if (existing != null) {
      return Conversation.fromMap(existing, myId: _uid);
    }

    final created = await _client
        .from('conversations')
        .insert({'user_a': a, 'user_b': b})
        .select()
        .single();

    return Conversation.fromMap(created, myId: _uid);
  }

  Future<List<Conversation>> fetchInbox() async {
    final rows = await _client
        .from('conversations')
        .select('''
          *,
          user_a_profile:users!conversations_user_a_fkey(full_name),
          user_b_profile:users!conversations_user_b_fkey(full_name)
        ''')
        .or('user_a.eq.$_uid,user_b.eq.$_uid')
        .order('last_message_at', ascending: false, nullsFirst: false);

    return (rows as List).map((r) => Conversation.fromMap(r, myId: _uid)).toList();
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId) async {
    final rows = await _client
        .from('messages')
        .select()
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true);
    return (rows as List).map((r) => ChatMessage.fromMap(r)).toList();
  }

  Future<void> sendMessage({
    required String conversationId,
    required String content,
  }) async {
    await _client.from('messages').insert({
      'conversation_id': conversationId,
      'sender_id': _uid,
      'content': content.trim(),
    });
  }

  Future<void> markConversationRead(String conversationId) async {
    final convo = await _client
        .from('conversations')
        .select('user_a, user_b')
        .eq('id', conversationId)
        .single();

    final column = convo['user_a'] == _uid ? 'last_read_at_a' : 'last_read_at_b';

    await _client
        .from('conversations')
        .update({column: DateTime.now().toIso8601String()})
        .eq('id', conversationId);
  }

  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('conversation_id', conversationId)
        .order('created_at', ascending: true)
        .map((rows) => rows.map((r) => ChatMessage.fromMap(r)).toList());
  }

  Stream<List<Map<String, dynamic>>> watchMyConversations() {
    return _client
        .from('conversations')
        .stream(primaryKey: ['id'])
        .order('last_message_at', ascending: false)
        .map((rows) => rows
            .where((r) => r['user_a'] == _uid || r['user_b'] == _uid)
            .toList());
  }
}