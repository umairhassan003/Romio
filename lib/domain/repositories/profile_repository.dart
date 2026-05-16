import '../models/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile(String userId);
  Future<Profile> updateProfile(Profile profile);
  Future<Profile> createProfile(Profile profile);
}
