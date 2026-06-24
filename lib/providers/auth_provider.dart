import 'package:flutter/material.dart';
import '../api/auth_api.dart';
import '../api/ride_api.dart';

class AuthProvider extends ChangeNotifier {
  final AuthApi _api = AuthApi();
  final RideApi _rideApi = RideApi();

  bool isLoading = false;
  String? error;
  String? pendingEmail;

  bool get isLoggedIn => _api.isLoggedIn;

  Future<bool> register({
    required String name,
    required String phone,
    required String gender,
    required String email,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _api.register(
        name: name,
        phone: phone,
        gender: gender,
        email: email,
        password: password,
      );
      pendingEmail = email;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifySignupOtp(String otp) async {
    if (pendingEmail == null) return false;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _api.verifySignupOtp(email: pendingEmail!, otp: otp);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendOtp() async {
    if (pendingEmail == null) return false;
    try {
      await _api.resendSignupOtp(email: pendingEmail!);
      return true;
    } catch (e) {
      error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _api.login(email: email, password: password);

      final profile = await _rideApi.getMyProfile();
      if (profile.isBanned) {
        await _api.logout();
        error = 'Your account has been suspended. Contact admin@lus.ac.bd';
        isLoading = false;
        notifyListeners();
        return false;
      }

      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> requestPasswordReset(String email) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _api.requestPasswordReset(email: email);
      pendingEmail = email;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyRecoveryOtp(String otp) async {
    if (pendingEmail == null) return false;
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _api.verifyRecoveryOtp(email: pendingEmail!, otp: otp);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      await _api.updatePassword(newPassword: newPassword);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    notifyListeners();
  }

  Future<bool> hasValidSession() => _api.hasValidSession();
}