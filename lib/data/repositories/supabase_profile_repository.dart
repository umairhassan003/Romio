import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/profile.dart';
import '../../domain/repositories/profile_repository.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _supabaseClient;
  static const String tableName = 'profiles';

  SupabaseProfileRepository({SupabaseClient? client}) 
      : _supabaseClient = client ?? Supabase.instance.client;

  @override
  Future<Profile?> getProfile(String userId) async {
    try {
      final response = await _supabaseClient
          .from(tableName)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return Profile.fromJson(response);
    } catch (e) {
      // In a real app we might want to log this or throw a custom exception
      rethrow;
    }
  }

  @override
  Future<Profile> updateProfile(Profile profile) async {
    final response = await _supabaseClient
        .from(tableName)
        .update(profile.toJson())
        .eq('id', profile.id)
        .select()
        .single();
    
    return Profile.fromJson(response);
  }

  @override
  Future<Profile> createProfile(Profile profile) async {
    final response = await _supabaseClient
        .from(tableName)
        .insert(profile.toJson())
        .select()
        .single();
        
    return Profile.fromJson(response);
  }
}
