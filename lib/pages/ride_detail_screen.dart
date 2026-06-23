import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../entities/ride.dart';
import '../widgets/map_thumbnail.dart';
import '../widgets/ride_card.dart';
import '../api/auth_api.dart';
import '../providers/chat_provider.dart';
import 'package:provider/provider.dart';
import 'chat_screen.dart';

class RideDetailScreen extends StatefulWidget {
  final Ride ride;

  const RideDetailScreen({super.key, required this.ride});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  bool _openingChat = false;

  Future<void> _call(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openChat() async {
    setState(() => _openingChat = true);
    final chatProvider = context.read<ChatProvider>();
    try {
      final convo = await chatProvider.openOrCreateConversation(widget.ride.riderId);
      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            conversationId: convo.id,
            otherUserId: widget.ride.riderId,
            otherUserName: widget.ride.riderName ?? 'Rider',
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open chat: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) setState(() => _openingChat = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    final myId = AuthApi().currentUserId;
    final isOwnRide = myId != null && myId == ride.riderId;

    return Scaffold(
      appBar: AppBar(title: const Text('Ride Detail')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              MapThumbnail(lat: ride.pickupLat, lng: ride.pickupLng),
              const SizedBox(height: 16),
              Text(ride.directionLabel, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(vehicleIcon(ride.vehicleType)),
                  const SizedBox(width: 8),
                  Text(ride.vehicleType.toUpperCase()),
                  if (ride.route != null) ...[
                    const SizedBox(width: 16),
                    Text('Route ${ride.route}'),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(ride.riderName ?? 'Rider'),
                subtitle: Text(ride.riderPhone ?? ''),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: ride.riderPhone == null ? null : () => _call(ride.riderPhone!),
                      icon: const Icon(Icons.call),
                      label: const Text('Call Rider'),
                    ),
                  ),
                  if (!isOwnRide) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _openingChat ? null : _openChat,
                        icon: _openingChat
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.chat_bubble_outline),
                        label: const Text('Chat with Rider'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}