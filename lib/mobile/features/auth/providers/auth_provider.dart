import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;

  User? _user;
  bool _isLoading = false;

  AuthProvider({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository {
    _init();
  }

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  void _init() {
    _authRepository.authStateChanges.listen((data) {
      _user = data.session?.user;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.signInWithEmailPassword(email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, {String? firstName, String? lastName}) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.signUpWithEmailPassword(
        email, 
        password,
        data: {
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
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
      await _authRepository.signOut();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
