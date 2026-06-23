import 'package:supabase_flutter/supabase_flutter.dart';
import '../entities/app_user.dart';
import '../entities/ride.dart';
import '../entities/ride_request.dart';

class AdminApi {
  final SupabaseClient _client = Supabase.instance.client;

  Future<Map<String, int>> fetchStats() async {
    final todayStart = DateTime.now().toUtc().copyWith(
          hour: 0,
          minute: 0,
          second: 0,
          millisecond: 0,
          microsecond: 0,
        );

    final totalUsers = await _client.from('users').count();
    final bannedUsers = await _client.from('users').count(CountOption.exact).eq('is_banned', true);
    final activeRides = await _client
        .from('rides')
        .count(CountOption.exact)
        .inFilter('status', ['offered', 'booked']);
    final activeRequests = await _client
        .from('ride_requests')
        .count(CountOption.exact)
        .eq('status', 'requested');
    final ridesToday = await _client
        .from('rides')
        .count(CountOption.exact)
        .gte('created_at', todayStart.toIso8601String());
    final requestsToday = await _client
        .from('ride_requests')
        .count(CountOption.exact)
        .gte('created_at', todayStart.toIso8601String());

    return {
      'total_users': totalUsers,
      'banned_users': bannedUsers,
      'active_rides': activeRides,
      'active_requests': activeRequests,
      'rides_today': ridesToday,
      'requests_today': requestsToday,
    };
  }

  Future<List<AppUser>> fetchAllUsers() async {
    final res = await _client
        .from('users')
        .select()
        .order('created_at', ascending: false);
    return (res as List).map((m) => AppUser.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<void> setBanned(String userId, bool banned) async {
    await _client.from('users').update({'is_banned': banned}).eq('id', userId);
  }

  Future<List<Ride>> fetchActiveRides() async {
    final res = await _client
        .from('rides')
        .select('*, users:rider_id(full_name, phone)')
        .inFilter('status', ['offered', 'booked'])
        .order('created_at', ascending: false);
    return (res as List).map((m) => Ride.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<void> forceCancelRide(String rideId) async {
    await _client
        .from('rides')
        .update({'status': 'cancelled', 'closed_at': DateTime.now().toIso8601String()})
        .eq('id', rideId);
  }

  Future<List<RideRequest>> fetchActiveRequests() async {
    final res = await _client
        .from('ride_requests')
        .select('*, users:requester_id(full_name)')
        .eq('status', 'requested')
        .order('created_at', ascending: false);
    return (res as List).map((m) => RideRequest.fromMap(m as Map<String, dynamic>)).toList();
  }

  Future<void> forceCancelRequest(String requestId) async {
    await _client
        .from('ride_requests')
        .update({'status': 'cancelled', 'closed_at': DateTime.now().toIso8601String()})
        .eq('id', requestId);
  }
}