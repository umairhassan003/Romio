import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_exception.dart';
import '../../../../domain/models/admin_user.dart';

class AdminAuthProvider extends ChangeNotifier {
  final SupabaseClient _client;

  AdminAuthProvider({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  AdminUser? _currentAdmin;
  bool _isLoading = false;
  bool _isCheckingAuth = true;
  AppException? _error;

  AdminUser? get currentAdmin => _currentAdmin;
  bool get isLoading => _isLoading;
  bool get isCheckingAuth => _isCheckingAuth;
  AppException? get error => _error;
  bool get isSuperAdmin => _currentAdmin?.role == 'super_admin';
  bool get isAuthenticated => _currentAdmin != null;

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _client.auth.signInWithPassword(email: email, password: password);
      await _verifyAdminAccess();
    } on AuthException catch (e) {
      _error = AppException(e.message, code: 'AUTH_ERROR');
    } on AppException catch (e) {
      _error = e;
    } catch (e) {
      _error = AppException('Error inesperado: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _verifyAdminAccess() async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AppException('No hay sesión activa', code: 'NO_SESSION');
    }
    try {
      final response = await _client
          .from('admin_users')
          .select()
          .eq('user_id', user.id)
          .eq('is_active', true)
          .maybeSingle();

      if (response == null) {
        await _client.auth.signOut();
        throw const AppException(
          'Tu cuenta no tiene acceso al panel de administración.',
          code: 'ACCESS_DENIED',
        );
      }
      _currentAdmin = AdminUser.fromJson(response);
    } on AppException {
      rethrow;
    } on PostgrestException catch (e) {
      throw AppException(e.message, code: e.code);
    }
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
    _currentAdmin = null;
    _error = null;
    notifyListeners();
  }

  Future<void> checkSession() async {
    _isCheckingAuth = true;
    notifyListeners();
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        _currentAdmin = null;
        return;
      }
      await _verifyAdminAccess();
    } catch (_) {
      _currentAdmin = null;
    } finally {
      _isCheckingAuth = false;
      notifyListeners();
    }
  }
}
