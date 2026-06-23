import 'dart:async';
import 'package:flutter/material.dart';
import '../api/ride_api.dart';
import '../entities/ride.dart';
import '../entities/app_user.dart';
import '../entities/ride_request.dart';

class RideProvider extends ChangeNotifier {
  final RideApi _api = RideApi();

  List<Ride> activeFeed = [];
  List<Ride> latestRides = [];
  List<Ride> myHistory = [];
  Ride? myActiveRide;
  AppUser? myProfile;

  List<RideRequest> activeRequests = [];
  RideRequest? myActiveRequest;
  StreamSubscription? _requestSub;

  bool isLoading = false;
  String? error;

  StreamSubscription? _feedSub;

  Future<void> loadDashboard() async {
    isLoading = true;
    notifyListeners();
    try {
      myProfile = await _api.getMyProfile();
      activeFeed = await _api.fetchActiveFeed();
      latestRides = await _api.fetchLatestRides();
      myActiveRide = await _api.fetchMyActiveRide();
      myActiveRequest = await _api.fetchMyActiveRequest();
      activeRequests = await _api.fetchActiveRequests();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  void subscribeToFeed() {
    _feedSub?.cancel();
    _feedSub = _api.watchActiveFeed().listen((rides) {
      activeFeed = rides;
      notifyListeners();
    });
  }

  void unsubscribeFeed() {
    _feedSub?.cancel();
    _feedSub = null;
  }

  void subscribeToRequests() {
    _requestSub?.cancel();
    _requestSub = _api.watchActiveRequests().listen((requests) {
      activeRequests = requests;
      notifyListeners();
    });
  }

  void unsubscribeRequests() {
    _requestSub?.cancel();
    _requestSub = null;
  }

  Future<bool> createRequest({
    required double lat,
    required double lng,
    required List<int> routes,
    required String direction,
  }) async {
    try {
      await _api.createRequest(
        lat: lat,
        lng: lng,
        routes: routes,
        direction: direction,
      );
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markRequestCompleted(String requestId) async {
    try {
      await _api.markRequestCompleted(requestId);
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markRequestCancelled(String requestId) async {
    try {
      await _api.markRequestCancelled(requestId);
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> loadHistory() async {
    isLoading = true;
    notifyListeners();
    try {
      myHistory = await _api.fetchMyHistory();
    } catch (e) {
      error = e.toString();
    }
    isLoading = false;
    notifyListeners();
  }

  Future<bool> offerRide({
    required String direction,
    required double lat,
    required double lng,
    required String vehicleType,
    int? route,
  }) async {
    try {
      await _api.offerRide(
        direction: direction,
        lat: lat,
        lng: lng,
        vehicleType: vehicleType,
        route: route,
      );
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markBooked(String rideId) async {
    try {
      await _api.markBooked(rideId);
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markCancelled(String rideId) async {
    try {
      await _api.markCancelled(rideId);
      await loadDashboard();
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    _feedSub?.cancel();
    _requestSub?.cancel();
    super.dispose();
  }
}