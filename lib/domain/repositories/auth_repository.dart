import 'package:supabase_flutter/supabase_flutter.dart';

abstract class AuthRepository {
  Stream<AuthState> get authStateChanges;
  User? get currentUser;
  
  Future<AuthResponse> signInWithEmailPassword(String email, String password);
  Future<AuthResponse> signUpWithEmailPassword(String email, String password, {Map<String, dynamic>? data});
  Future<void> signOut();
  Future<void> resetPasswordForEmail(String email);
  Future<void> verifyRecoveryOtp({required String email, required String token});
  Future<void> updateUserPassword(String newPassword);
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}
