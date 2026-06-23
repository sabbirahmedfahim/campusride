import 'package:flutter/material.dart';
import '../entities/ride.dart';
import 'map_thumbnail.dart';

IconData vehicleIcon(String type) {
  switch (type) {
    case 'car':
      return Icons.directions_car;
    case 'bike':
      return Icons.two_wheeler;
    case 'cng':
    default:
      return Icons.electric_rickshaw;
  }
}

class RideCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback onTap;

  const RideCard({super.key, required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 90,
                  height: 70,
                  child: MapThumbnail(
                    lat: ride.pickupLat,
                    lng: ride.pickupLng,
                    tappable: false,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Chip(
                          label: Text(ride.directionLabel),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                        const SizedBox(width: 6),
                        Icon(vehicleIcon(ride.vehicleType), size: 18),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      ride.riderName ?? 'Rider',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    if (ride.route != null)
                      Text('Route ${ride.route}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}