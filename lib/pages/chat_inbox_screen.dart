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
  static const Color kPrimaryColor = Color(0xFF10B981);
  static const Color kSurfaceColor = Color(0xFF051424);
  static const Color kCardColor = Color(0xFF111E2F);

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
      backgroundColor: kSurfaceColor,
      appBar: AppBar(
        backgroundColor: kSurfaceColor,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
          ),
        ),
      ),
      body: provider.isLoadingInbox && provider.inbox.isEmpty
          ? const Center(
              child: CircularProgressIndicator(
                color: kPrimaryColor,
              ),
            )
          : provider.inbox.isEmpty
              ? Center(
                  child: Text(
                    'No conversations yet.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 15,
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: provider.loadInbox,
                  color: kPrimaryColor,
                  backgroundColor: kCardColor,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: kPrimaryColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: kPrimaryColor.withOpacity(0.4),
                                  blurRadius: 8,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${provider.inbox.length} conversation${provider.inbox.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ...provider.inbox.map(
                        (convo) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              cardColor: kCardColor,
                            ),
                            child: ConversationTile(
                              conversation: convo,
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      conversationId: convo.id,
                                      otherUserId: myId == null
                                          ? ''
                                          : convo.otherUserId(myId),
                                      otherUserName:
                                          convo.otherUserName ?? 'Unknown User',
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}