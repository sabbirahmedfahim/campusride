import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../api/auth_api.dart';
import '../widgets/conversation_tile.dart';
import 'chat_screen.dart';

class ChatInboxScreen extends StatefulWidget {
  const ChatInboxScreen({super.key});

  @override
  State<ChatInboxScreen> createState() => _ChatInboxScreenState();
}

class _ChatInboxScreenState extends State<ChatInboxScreen> {
  @override
  void initState() {
    super.initState();
    final provider = context.read<ChatProvider>();
    _init(provider);
  }

  Future<void> _init(ChatProvider provider) async {
    await provider.loadInbox();
    provider.subscribeToInbox();
    await provider.markAllInboxRead();
  }

  @override
  void dispose() {
    context.read<ChatProvider>().unsubscribeInbox();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();
    final myId = AuthApi().currentUserId;

    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: provider.isLoadingInbox && provider.inbox.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.inbox.isEmpty
              ? const Center(child: Text('No conversations yet.'))
              : RefreshIndicator(
                  onRefresh: provider.loadInbox,
                  child: ListView.builder(
                    itemCount: provider.inbox.length,
                    itemBuilder: (context, i) {
                      final convo = provider.inbox[i];
                      return ConversationTile(
                        conversation: convo,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                conversationId: convo.id,
                                otherUserId: myId == null ? '' : convo.otherUserId(myId),
                                otherUserName: convo.otherUserName ?? 'Unknown User',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
    );
  }
}