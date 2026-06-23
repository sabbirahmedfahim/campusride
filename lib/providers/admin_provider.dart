import 'package:flutter/material.dart';
import '../api/admin_api.dart';
import '../entities/app_user.dart';
import '../entities/ride.dart';
import '../entities/ride_request.dart';

class AdminProvider extends ChangeNotifier {
  final AdminApi _api = AdminApi();

  Map<String, int>? stats;
  bool isLoadingStats = false;

  List<AppUser> allUsers = [];
  bool isLoadingUsers = false;

  List<Ride> activeRides = [];
  bool isLoadingRides = false;

  List<RideRequest> activeRequests = [];
  bool isLoadingRequests = false;

  String? error;

  Future<void> loadStats() async {
    isLoadingStats = true;
    notifyListeners();
    try {
      stats = await _api.fetchStats();
    } catch (e) {
      error = e.toString();
    }
    isLoadingStats = false;
    notifyListeners();
  }

  Future<void> loadAllUsers() async {
    isLoadingUsers = true;
    notifyListeners();
    try {
      allUsers = await _api.fetchAllUsers();
    } catch (e) {
      error = e.toString();
    }
    isLoadingUsers = false;
    notifyListeners();
  }

  Future<void> toggleBan(String userId, bool banned) async {
    try {
      await _api.setBanned(userId, banned);
      final idx = allUsers.indexWhere((u) => u.id == userId);
      if (idx != -1) {
        await loadAllUsers();
      }
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadActiveRides() async {
    isLoadingRides = true;
    notifyListeners();
    try {
      activeRides = await _api.fetchActiveRides();
    } catch (e) {
      error = e.toString();
    }
    isLoadingRides = false;
    notifyListeners();
  }

  Future<void> forceCancelRide(String rideId) async {
    try {
      await _api.forceCancelRide(rideId);
      activeRides.removeWhere((r) => r.id == rideId);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadActiveRequests() async {
    isLoadingRequests = true;
    notifyListeners();
    try {
      activeRequests = await _api.fetchActiveRequests();
    } catch (e) {
      error = e.toString();
    }
    isLoadingRequests = false;
    notifyListeners();
  }

  Future<void> forceCancelRequest(String requestId) async {
    try {
      await _api.forceCancelRequest(requestId);
      activeRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    } catch (e) {
      error = e.toString();
      notifyListeners();
    }
  }
}