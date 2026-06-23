import 'package:supabase_flutter/supabase_flutter.dart';

class AuthApi {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  bool get isLoggedIn => _client.auth.currentSession != null;
  String? get currentUserId => _client.auth.currentUser?.id;

  Future<void> register({
    required String name,
    required String phone,
    required String gender,
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'phone': phone,
          'gender': gender,
        },
      );
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  Future<void> verifySignupOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.signup,
      );
    } catch (e) {
      throw Exception('Invalid or expired code. Please try again.');
    }
  }

  Future<void> resendSignupOtp({required String email}) async {
    try {
      await _client.auth.resend(type: OtpType.signup, email: email);
    } catch (e) {
      throw Exception('Could not resend code: ${e.toString()}');
    }
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<void> requestPasswordReset({required String email}) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('Could not send reset code: ${e.toString()}');
    }
  }

  Future<void> verifyRecoveryOtp({
    required String email,
    required String otp,
  }) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: otp,
        type: OtpType.recovery,
      );
    } catch (e) {
      throw Exception('Invalid or expired code. Please try again.');
    }
  }

  Future<void> updatePassword({required String newPassword}) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception('Could not update password: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _client.auth.signOut();
  }

  Future<bool> hasValidSession() async {
    final session = _client.auth.currentSession;
    if (session == null) return false;
    return !session.isExpired;
  }
}