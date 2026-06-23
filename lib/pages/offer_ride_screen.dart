import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../widgets/map_thumbnail.dart';

class OfferRideScreen extends StatefulWidget {
  final String direction;

  const OfferRideScreen({super.key, required this.direction});

  @override
  State<OfferRideScreen> createState() => _OfferRideScreenState();
}

enum _GpsState { loading, success, failure }

class _OfferRideScreenState extends State<OfferRideScreen> {
  _GpsState _state = _GpsState.loading;
  String _errorMessage = '';
  double? _lat;
  double? _lng;

  String _vehicleType = 'cng';
  int? _route;
  bool _posting = false;

  static const Color kPrimaryColor = Color(0xFF10B981);
  static const Color kSurfaceColor = Color(0xFF051424);
  static const Color kCardColor = Color(0xFF111E2F);
  static const Color kAccentColor = Color(0xFF2DD4BF);

  @override
  void initState() {
    super.initState();
    _acquireLocation();
  }

  Future<void> _acquireLocation() async {
    setState(() => _state = _GpsState.loading);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _fail('Location services are disabled — please enable GPS to offer a ride.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _fail('Location permission denied — enable location access to offer a ride.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _fail('Location permission permanently denied — enable it from app settings to offer a ride.');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      if (!mounted) return;
      setState(() {
        _lat = position.latitude;
        _lng = position.longitude;
        _state = _GpsState.success;
      });
    } on Exception {
      _fail('Could not get a GPS fix — please try again.');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _state = _GpsState.failure;
      _errorMessage = message;
    });
  }

  Future<void> _post() async {
    if (_lat == null || _lng == null) return;

    setState(() => _posting = true);
    final provider = context.read<RideProvider>();
    final ok = await provider.offerRide(
      direction: widget.direction,
      lat: _lat!,
      lng: _lng!,
      vehicleType: _vehicleType,
      route: _route,
    );
    setState(() => _posting = false);

    if (ok && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not post ride — please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPost = _state == _GpsState.success && !_posting;

    return Scaffold(
      backgroundColor: kSurfaceColor,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildDirectionHeader(),
              const SizedBox(height: 24),
              _buildLocationSection(),
              const SizedBox(height: 32),
              if (_state == _GpsState.success) ...[
                const Text(
                  'Vehicle Type',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                _buildVehicleSelector(),
                const SizedBox(height: 32),
                const Text(
                  'Route Tag (optional)',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                _buildRouteSelector(),
              ],
              const Spacer(),
              _buildPostButton(canPost),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kSurfaceColor,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Offer a Ride',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Colors.white,
          letterSpacing: -0.8,
        ),
      ),
    );
  }

  Widget _buildDirectionHeader() {
    final label = widget.direction == 'from_lu' ? 'From Leading University' : 'To Leading University';
    final subtitle = widget.direction == 'from_lu' ? 'Campus to Sylhet City' : 'City to LU Campus';
    final icon = widget.direction == 'from_lu' ? Icons.north_east_rounded : Icons.south_west_rounded;
    final color = widget.direction == 'from_lu' ? kPrimaryColor : kAccentColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    switch (_state) {
      case _GpsState.loading:
        return Center(
          child: Column(
            children: [
              const SizedBox(height: 40),
              const CircularProgressIndicator(color: kPrimaryColor),
              const SizedBox(height: 20),
              Text(
                'Detecting your location…',
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );
      case _GpsState.failure:
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              const Icon(Icons.location_off_rounded, color: Colors.redAccent, size: 40),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500, height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  onPressed: _acquireLocation,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('RETRY GPS FIX', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
            ],
          ),
        );
      case _GpsState.success:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: MapThumbnail(lat: _lat!, lng: _lng!, tappable: false),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.my_location_rounded, size: 14, color: kPrimaryColor.withOpacity(0.8)),
                const SizedBox(width: 8),
                Text(
                  'Lat: ${_lat!.toStringAsFixed(6)} • Lng: ${_lng!.toStringAsFixed(6)}',
                  style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        );
    }
  }

  Widget _buildVehicleSelector() {
    final types = [
      {'val': 'cng', 'label': 'CNG', 'icon': Icons.electric_rickshaw_rounded},
      {'val': 'car', 'label': 'Car', 'icon': Icons.directions_car_filled_rounded},
      {'val': 'bike', 'label': 'Bike', 'icon': Icons.directions_bike_rounded},
    ];

    return Row(
      children: types.map((t) {
        final selected = _vehicleType == t['val'];
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _vehicleType = t['val'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: selected ? kPrimaryColor : kCardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selected ? kPrimaryColor : Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                children: [
                  Icon(t['icon'] as IconData, color: selected ? Colors.black : kAccentColor, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    t['label'] as String,
                    style: TextStyle(color: selected ? Colors.black : Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRouteSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 12,
      children: [
        _buildRouteChip('None', null),
        for (final r in [1, 2, 3, 4]) _buildRouteChip('R$r', r),
      ],
    );
  }

  Widget _buildRouteChip(String label, int? val) {
    final selected = _route == val;
    return GestureDetector(
      onTap: () => setState(() => _route = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? kAccentColor : kCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? kAccentColor : Colors.white.withOpacity(0.05)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.black : Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPostButton(bool canPost) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: canPost ? _post : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.white.withOpacity(0.05),
          disabledForegroundColor: Colors.white.withOpacity(0.1),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        child: _posting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 3, color: Colors.black),
              )
            : const Text('POST RIDE OFFER'),
      ),
    );
  }
}