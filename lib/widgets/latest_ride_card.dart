import 'dart:async';
import 'package:flutter/material.dart';
import '../entities/ride.dart';
import 'ride_card.dart';

String relativeTime(DateTime dt) {
  final diff = DateTime.now().difference(dt);
  if (diff.isNegative || diff.inMinutes < 1) return 'just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  return '${diff.inDays}d ago';
}

class LatestRideCard extends StatefulWidget {
  final Ride ride;

  const LatestRideCard({super.key, required this.ride});

  @override
  State<LatestRideCard> createState() => _LatestRideCardState();
}

class _LatestRideCardState extends State<LatestRideCard> {
  Timer? _ticker;

  static const Color kPrimaryColor = Color(0xFF10B981);
  static const Color kSurfaceColor = Color(0xFF051424);
  static const Color kCardColor = Color(0xFF111E2F);
  static const Color kAccentColor = Color(0xFF2DD4BF);

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ride = widget.ride;
    
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                vehicleIcon(ride.vehicleType), 
                size: 20, 
                color: kAccentColor.withOpacity(0.8)
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ride.directionLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 9, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white.withOpacity(0.4),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            ride.riderName ?? 'Unknown Rider',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              letterSpacing: -0.3,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.access_time_rounded, 
                size: 10, 
                color: Colors.white.withOpacity(0.3)
              ),
              const SizedBox(width: 4),
              Text(
                ride.closedAt != null ? relativeTime(ride.closedAt!) : 'completed',
                style: TextStyle(
                  fontSize: 11, 
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}