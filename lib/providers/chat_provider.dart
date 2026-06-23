import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../api/chat_api.dart';
import '../entities/conversation.dart';
import '../entities/chat_message.dart';

class ChatProvider extends ChangeNotifier {
  final ChatApi _api = ChatApi();
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid => _client.auth.currentUser!.id;

  List<Conversation> inbox = [];
  bool isLoadingInbox = false;
  String? error;

  StreamSubscription? _inboxSub;

  bool get hasUnread => inbox.any((c) => c.isUnreadFor(_uid));

  Future<void> loadInbox() async {
    isLoadingInbox = true;
    notifyListeners();
    try {
      inbox = await _api.fetchInbox();
    } catch (e) {
      error = e.toString();
    }
    isLoadingInbox = false;
    notifyListeners();
  }

  void subscribeToInbox() {
    _inboxSub?.cancel();
    _inboxSub = _api.watchMyConversations().listen((_) {
      loadInbox();
    });
  }

  void unsubscribeInbox() {
    _inboxSub?.cancel();
    _inboxSub = null;
  }

  Future<Conversation> openOrCreateConversation(String otherUserId) {
    return _api.getOrCreateConversation(otherUserId);
  }

  List<ChatMessage> messages = [];
  bool isLoadingMessages = false;
  StreamSubscription? _messagesSub;

  Future<void> loadMessages(String conversationId) async {
    isLoadingMessages = true;
    notifyListeners();
    try {
      messages = await _api.fetchMessages(conversationId);
    } catch (e) {
      error = e.toString();
    }
    isLoadingMessages = false;
    notifyListeners();
  }

  void subscribeToMessages(String conversationId) {
    _messagesSub?.cancel();
    _messagesSub = _api.watchMessages(conversationId).listen((msgs) {
      messages = msgs;
      notifyListeners();
    });
  }

  void unsubscribeMessages() {
    _messagesSub?.cancel();
    _messagesSub = null;
  }

  Future<bool> sendMessage(String conversationId, String content) async {
    if (content.trim().isEmpty) return false;
    try {
      await _api.sendMessage(conversationId: conversationId, content: content);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> markConversationRead(String conversationId) async {
    try {
      await _api.markConversationRead(conversationId);
    } catch (_) {
    }
  }

  Future<void> markAllInboxRead() async {
    final unread = inbox.where((c) => c.isUnreadFor(_uid)).toList();
    for (final c in unread) {
      await markConversationRead(c.id);
    }
  }

  @override
  void dispose() {
    _inboxSub?.cancel();
    _messagesSub?.cancel();
    super.dispose();
  }
}