import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _user;
  bool _isLoading = false;
  bool _isRecoveryVerified = false;

  AuthProvider({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository {
    _init();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  /// True only after Supabase accepted the recovery OTP for this session.
  bool get canResetPassword => _isRecoveryVerified && isAuthenticated;

  void _init() {
    _authRepository.authStateChanges.listen((data) {
      _user = data.session?.user;
      if (data.event == AuthChangeEvent.signedOut) {
        _isRecoveryVerified = false;
      }
      notifyListeners();
    });
  }

  void _clearRecoveryState() {
    _isRecoveryVerified = false;
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      _clearRecoveryState();
      await _authRepository.signInWithEmailPassword(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, {String? firstName, String? lastName, String? city}) async {
    _isLoading = true;
    notifyListeners();
    try {
      _clearRecoveryState();
      await _authRepository.signUpWithEmailPassword(
        email,
        password,
        data: {
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (city != null && city.isNotEmpty) 'city': city,
        }
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    try {
      _clearRecoveryState();
      await _authRepository.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      _clearRecoveryState();
      await _authRepository.resetPasswordForEmail(email);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> verifyRecoveryOtp({
    required String email,
    required String token,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.verifyRecoveryOtp(email: email, token: token);
      _isRecoveryVerified = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePassword(String newPassword) async {
    if (!canResetPassword) {
      throw const AuthException('Recovery session required');
    }

    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.updateUserPassword(newPassword);
      _clearRecoveryState();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
