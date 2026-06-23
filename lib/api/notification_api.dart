import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/notification_item.dart';

class NotificationApi {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid => _client.auth.currentUser!.id;

  Future<List<NotificationItem>> fetchMyNotifications() async {
    final rows = await _client
        .from('notifications')
        .select('*, rides(direction, users!rides_rider_id_fkey(full_name))')
        .eq('user_id', _uid)
        .order('created_at', ascending: false);
    return (rows as List).map((r) => NotificationItem.fromMap(r)).toList();
  }

  Future<int> fetchUnreadCount() async {
    final rows = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', _uid)
        .eq('is_read', false);
    return (rows as List).length;
  }

  Future<void> markAllRead() async {
    await _client
        .from('notifications')
        .update({'is_read': true})
        .eq('user_id', _uid)
        .eq('is_read', false);
  }

  Stream<List<NotificationItem>> watchUnread() {
    return _client
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _uid)
        .map((rows) => rows
            .where((r) => r['is_read'] == false)
            .map((r) => NotificationItem.fromMap(r))
            .toList());
  }
}