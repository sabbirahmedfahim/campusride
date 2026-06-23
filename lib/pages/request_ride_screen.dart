import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../providers/ride_provider.dart';
import '../widgets/map_thumbnail.dart';

class RequestRideScreen extends StatefulWidget {
  final String direction;

  const RequestRideScreen({super.key, required this.direction});

  @override
  State<RequestRideScreen> createState() => _RequestRideScreenState();
}

enum _GpsState { loading, success, failure }

class _RequestRideScreenState extends State<RequestRideScreen> {
  _GpsState _gpsState = _GpsState.loading;
  String _errorMessage = '';
  double? _lat;
  double? _lng;

  final Set<int> _selectedRoutes = {};
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
    setState(() => _gpsState = _GpsState.loading);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _fail('Location services are disabled — please enable GPS to request a ride.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _fail('Location permission denied — enable location access to request a ride.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _fail('Location permission permanently denied — enable it from app settings.');
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
        _gpsState = _GpsState.success;
      });
    } on Exception {
      _fail('Could not get a GPS fix — please try again.');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _gpsState = _GpsState.failure;
      _errorMessage = message;
    });
  }

  Future<void> _submit() async {
    if (_lat == null || _lng == null || _selectedRoutes.isEmpty) return;

    setState(() => _posting = true);
    final provider = context.read<RideProvider>();
    final bool ok = await provider.createRequest(
      lat: _lat!,
      lng: _lng!,
      routes: _selectedRoutes.toList()..sort(),
      direction: widget.direction,
    );
    setState(() => _posting = false);

    if (ok && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Could not submit request — please try again.'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = _gpsState == _GpsState.success && _selectedRoutes.isNotEmpty && !_posting;

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
              if (_gpsState == _GpsState.success) ...[
                const Text(
                  'Select Routes',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Select all routes you are willing to use.',
                  style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [1, 2, 3, 4].map((r) {
                    final selected = _selectedRoutes.contains(r);
                    return _buildRouteChip(r, selected);
                  }).toList(),
                ),
                if (_selectedRoutes.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 12),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline_rounded, color: Colors.redAccent, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'At least one route must be selected.',
                          style: TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
              ],
              const Spacer(),
              _buildSubmitButton(canSubmit),
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
        'Request a Ride',
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
    switch (_gpsState) {
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

  Widget _buildRouteChip(int r, bool selected) {
    return GestureDetector(
      onTap: () => setState(() {
        if (selected) {
          _selectedRoutes.remove(r);
        } else {
          _selectedRoutes.add(r);
        }
      }),
      child: Container(
        width: (MediaQuery.of(context).size.width - 72) / 2,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : kCardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? kPrimaryColor : Colors.white.withOpacity(0.05),
          ),
          boxShadow: selected ? [BoxShadow(color: kPrimaryColor.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 4))] : [],
        ),
        child: Column(
          children: [
            Text(
              'R$r',
              style: TextStyle(
                color: selected ? Colors.black : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Route $r',
              style: TextStyle(
                color: selected ? Colors.black.withOpacity(0.5) : Colors.white.withOpacity(0.3),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(bool canSubmit) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: canSubmit ? _submit : null,
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
            : const Text('SUBMIT REQUEST'),
      ),
    );
  }
}