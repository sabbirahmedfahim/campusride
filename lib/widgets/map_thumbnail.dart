import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class MapThumbnail extends StatelessWidget {
  final double lat;
  final double lng;
  final bool tappable;

  const MapThumbnail({
    super.key,
    required this.lat,
    required this.lng,
    this.tappable = true,
  });

  Future<void> _openInMaps() async {
    final geo = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final web = Uri.parse(
        'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (await canLaunchUrl(geo)) {
      await launchUrl(geo);
    } else {
      await launchUrl(web, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final position = LatLng(lat, lng);

    final mapWidget = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        height: 160,
        child: AbsorbPointer(
          absorbing: true,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: position,
              zoom: 16,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('pickup'),
                position: position,
              ),
            },
            zoomControlsEnabled: false,
            zoomGesturesEnabled: false,
            scrollGesturesEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            liteModeEnabled: true,
          ),
        ),
      ),
    );

    if (!tappable) return mapWidget;

    return Stack(
      children: [
        mapWidget,
        Positioned.fill(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openInMaps,
                splashColor: Colors.black12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}