import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/ride.dart';
import '../entities/app_user.dart';
import '../entities/ride_request.dart';


class RideApi {
  final SupabaseClient _client = Supabase.instance.client;

  String get _uid => _client.auth.currentUser!.id;

  Future<AppUser> getMyProfile() async {
    final row = await _client.from('users').select().eq('id', _uid).single();
    return AppUser.fromMap(row);
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
  }) async {
    await _client.from('users').update({
      'full_name': fullName,
      'phone': phone,
    }).eq('id', _uid);
  }

  Future<List<Ride>> fetchActiveFeed() async {
    final rows = await _client
        .from('rides')
        .select('*, users!rides_rider_id_fkey(full_name, phone)')
        .eq('status', 'offered')
        .order('created_at', ascending: false);
    return (rows as List).map((r) => Ride.fromMap(r)).toList();
  }

  Future<Ride?> fetchMyActiveRide() async {
    final rows = await _client
        .from('rides')
        .select()
        .eq('rider_id', _uid)
        .eq('status', 'offered')
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return Ride.fromMap(rows.first);
  }

  Stream<List<Ride>> watchActiveFeed() {
    return _client
        .from('rides')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows
            .where((r) => r['status'] == 'offered')
            .map((r) => Ride.fromMap(r))
            .toList());
  }

  Future<List<Ride>> fetchLatestRides() async {
    final rows = await _client
        .from('rides')
        .select('*, users!rides_rider_id_fkey(full_name, phone)')
        .eq('status', 'booked')
        .order('closed_at', ascending: false)
        .limit(10);
    return (rows as List).map((r) => Ride.fromMap(r)).toList();
  }

  Future<List<Ride>> fetchMyHistory() async {
    final rows = await _client
        .from('rides')
        .select()
        .eq('rider_id', _uid)
        .inFilter('status', ['booked', 'cancelled'])
        .order('closed_at', ascending: false);
    return (rows as List).map((r) => Ride.fromMap(r)).toList();
  }

  Future<void> offerRide({
    required String direction,
    required double lat,
    required double lng,
    required String vehicleType,
    int? route,
  }) async {
    await _client.from('rides').insert({
      'rider_id': _uid,
      'direction': direction,
      'pickup_lat': lat,
      'pickup_lng': lng,
      'vehicle_type': vehicleType,
      'route': route,
      'status': 'offered',
    });
  }

  Future<void> markBooked(String rideId) async {
    await _client
        .from('rides')
        .update({'status': 'booked', 'closed_at': DateTime.now().toIso8601String()})
        .eq('id', rideId)
        .eq('rider_id', _uid);
  }

  Future<void> markCancelled(String rideId) async {
    await _client
        .from('rides')
        .update({'status': 'cancelled', 'closed_at': DateTime.now().toIso8601String()})
        .eq('id', rideId)
        .eq('rider_id', _uid);
  }

  Future<List<RideRequest>> fetchActiveRequests() async {
    final rows = await _client
        .from('ride_requests')
        .select('*, users!ride_requests_requester_id_fkey(full_name)')
        .eq('status', 'requested')
        .order('created_at', ascending: false);
    return (rows as List).map((r) => RideRequest.fromMap(r)).toList();
  }

  Future<RideRequest?> fetchMyActiveRequest() async {
    final rows = await _client
        .from('ride_requests')
        .select()
        .eq('requester_id', _uid)
        .eq('status', 'requested')
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return RideRequest.fromMap(rows.first);
  }

  Stream<List<RideRequest>> watchActiveRequests() {
    return _client
        .from('ride_requests')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((rows) => rows
            .where((r) => r['status'] == 'requested')
            .map((r) => RideRequest.fromMap(r))
            .toList());
  }

  Future<void> createRequest({
    required double lat,
    required double lng,
    required List<int> routes,
    required String direction,
  }) async {
    await _client.from('ride_requests').insert({
      'requester_id': _uid,
      'pickup_lat': lat,
      'pickup_lng': lng,
      'routes': routes,
      'direction': direction,
      'status': 'requested',
    });
  }

  Future<void> markRequestCompleted(String requestId) async {
    await _client
        .from('ride_requests')
        .update({
          'status': 'completed',
          'closed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .eq('requester_id', _uid);
  }

  Future<void> markRequestCancelled(String requestId) async {
    await _client
        .from('ride_requests')
        .update({
          'status': 'cancelled',
          'closed_at': DateTime.now().toIso8601String(),
        })
        .eq('id', requestId)
        .eq('requester_id', _uid);
  }
}