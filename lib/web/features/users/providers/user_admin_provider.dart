import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../domain/models/profile.dart';

class UserAdminProvider extends ChangeNotifier {
  List<Profile> users = [];
  Profile? selectedUser;
  int totalCount = 0;
  int currentPage = 0;
  int pageSize = 25;
  String searchQuery = '';

  bool isLoading = false;
  String? error;

  // User detail stats
  int userReservationCount = 0;
  double userTotalSpend = 0;

  Future<void> loadUsers() async {
    isLoading = true; error = null; notifyListeners();
    try {
      final client = Supabase.instance.client;
      var query = client.from('profiles').select();
      if (searchQuery.isNotEmpty) {
        query = query.or('first_name.ilike.%$searchQuery%,last_name.ilike.%$searchQuery%');
      }
      final countResult = await client.from('profiles').select('id').count(CountOption.exact);
      totalCount = countResult.count;

      final response = await query
          .range(currentPage * pageSize, (currentPage + 1) * pageSize - 1)
          .order('created_at', ascending: false);
      users = (response as List).map((j) => Profile.fromJson(j)).toList();
    } catch (e) {
      error = 'Error al cargar usuarios: $e';
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  Future<void> loadUserById(String id) async {
    isLoading = true; error = null; notifyListeners();
    try {
      final client = Supabase.instance.client;
      final response = await client
          .from('profiles')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response != null) {
        selectedUser = Profile.fromJson(response);
      }

      // Load user stats
      final reservations = await client
          .from('reservations')
          .select('id, total_price')
          .eq('profile_id', id);
      userReservationCount = reservations.length;
      userTotalSpend = 0;
      for (final r in reservations) {
        userTotalSpend += (r['total_price'] as num).toDouble();
      }
    } catch (e) {
      error = 'Error al cargar usuario: $e';
    } finally {
      isLoading = false; notifyListeners();
    }
  }

  void setPage(int p) { currentPage = p; loadUsers(); }
  void search(String q) { searchQuery = q; currentPage = 0; loadUsers(); }
}
