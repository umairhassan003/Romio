import 'package:flutter/foundation.dart';
import '../../../../domain/models/profile.dart';
import '../../../../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileProvider({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get displayName {
    if (_profile == null) return 'Usuario';
    final first = _profile!.firstName ?? '';
    final last = _profile!.lastName ?? '';
    final full = '$first $last'.trim();
    return full.isEmpty ? 'Usuario' : full;
  }

  String get initials {
    if (_profile?.firstName?.isNotEmpty == true) {
      return _profile!.firstName![0].toUpperCase();
    }
    return 'U';
  }

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _profileRepository.getProfile(userId);
    } catch (e) {
      _error = e.toString();
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(Profile updatedProfile) async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _profileRepository.updateProfile(updatedProfile);
      return true;
    } catch (e) {
      _error = e.toString();
      debugPrint('Error updating profile: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateLanguage(String langCode) async {
    if (_profile == null) return false;
    final updated = _profile!.copyWith(
      preferredLanguage: langCode,
      updatedAt: DateTime.now(),
    );
    return updateProfile(updated);
  }

  Future<bool> updatePersonalInfo({
    String? firstName,
    String? lastName,
  }) async {
    if (_profile == null) return false;
    final updated = _profile!.copyWith(
      firstName: firstName ?? _profile!.firstName,
      lastName: lastName ?? _profile!.lastName,
      updatedAt: DateTime.now(),
    );
    return updateProfile(updated);
  }
}
