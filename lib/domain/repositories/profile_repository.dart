import '../models/profile.dart';

abstract class ProfileRepository {
  Future<Profile?> getProfile(String userId);
  Future<Profile> updateProfile(Profile profile);
  Future<Profile> createProfile(Profile profile);

  /// Permanently deletes the currently authenticated user's account
  /// (reservations, payments, profile and auth record) from the database.
  Future<void> deleteAccount();
}
