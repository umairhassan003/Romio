import 'package:flutter/foundation.dart';
import '../../../../domain/models/profile.dart';
import '../../../../domain/repositories/profile_repository.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  Profile? _profile;
  bool _isLoading = false;

  ProfileProvider({
    required ProfileRepository profileRepository,
  }) : _profileRepository = profileRepository;

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(String userId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _profileRepository.getProfile(userId);
    } catch (e) {
      debugPrint('Error fetching profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Future method extensions like updateAvatar, etc. can go here.
}
