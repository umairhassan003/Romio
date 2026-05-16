import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  final SupabaseClient _supabaseClient;

  SupabaseAuthRepository({SupabaseClient? client}) 
      : _supabaseClient = client ?? Supabase.instance.client;

  @override
  Stream<AuthState> get authStateChanges => _supabaseClient.auth.onAuthStateChange;

  @override
  User? get currentUser => _supabaseClient.auth.currentUser;

  @override
  Future<AuthResponse> signInWithEmailPassword(String email, String password) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<AuthResponse> signUpWithEmailPassword(String email, String password, {Map<String, dynamic>? data}) async {
    return await _supabaseClient.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  @override
  Future<void> signOut() async {
    await _supabaseClient.auth.signOut();
  }

  @override
  Future<void> resetPasswordForEmail(String email) async {
    await _supabaseClient.auth.resetPasswordForEmail(email);
  }
}
