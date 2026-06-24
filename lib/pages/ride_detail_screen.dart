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
  static const Color kPrimaryColor = Color(0xFF10B981);
  static const Color kSurfaceColor = Color(0xFF051424);
  static const Color kCardColor = Color(0xFF111E2F);
  static const Color kAccentColor = Color(0xFF2DD4BF);

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
      final convo =
          await chatProvider.openOrCreateConversation(widget.ride.riderId);

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
          SnackBar(
            content: Text('Could not open chat: ${e.toString()}'),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
          ),
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
      backgroundColor: kSurfaceColor,
      appBar: AppBar(
        backgroundColor: kSurfaceColor,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Ride Detail',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: MapThumbnail(
                  lat: ride.pickupLat,
                  lng: ride.pickupLng,
                ),
              ),
              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.directionLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Icon(
                          vehicleIcon(ride.vehicleType),
                          color: kPrimaryColor,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          ride.vehicleType.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (ride.route != null) ...[
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Route ${ride.route}',
                              style: const TextStyle(
                                color: kPrimaryColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Container(
                decoration: BoxDecoration(
                  color: kCardColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: kPrimaryColor,
                    ),
                  ),
                  title: Text(
                    ride.riderName ?? 'Rider',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    ride.riderPhone ?? '',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: ElevatedButton.icon(
                        onPressed: ride.riderPhone == null
                            ? null
                            : () => _call(ride.riderPhone!),
                        icon: const Icon(Icons.call),
                        label: const Text('Call Rider'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryColor,
                          foregroundColor: Colors.black,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (!isOwnRide) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 54,
                        child: OutlinedButton.icon(
                          onPressed: _openingChat ? null : _openChat,
                          icon: _openingChat
                              ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.chat_bubble_outline),
                          label: const Text('Chat with Rider'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.15),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                        ),
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