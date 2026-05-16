import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/analytics_repository.dart';

class SupabaseAnalyticsRepository implements AnalyticsRepository {
  final SupabaseClient _client;

  SupabaseAnalyticsRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  @override
  Future<Map<String, dynamic>> getDashboardStats() async {
    // Counts
    final hotelsCount = await _client.from('hotels').select('id').count(CountOption.exact);
    final roomsCount = await _client.from('rooms').select('id').count(CountOption.exact);
    final reservationsCount = await _client.from('reservations').select('id').count(CountOption.exact);
    final usersCount = await _client.from('profiles').select('id').count(CountOption.exact);

    // Total revenue from completed payments
    final payments = await _client
        .from('payments')
        .select('amount')
        .eq('status', 'completed');
    double totalRevenue = 0;
    for (final p in payments) {
      totalRevenue += (p['amount'] as num).toDouble();
    }

    // Recent reservations count (last 30 days)
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final recentReservations = await _client
        .from('reservations')
        .select('id')
        .gte('created_at', thirtyDaysAgo.toIso8601String())
        .count(CountOption.exact);

    return {
      'total_hotels': hotelsCount.count,
      'total_rooms': roomsCount.count,
      'total_reservations': reservationsCount.count,
      'total_users': usersCount.count,
      'total_revenue': totalRevenue,
      'recent_reservations': recentReservations.count,
    };
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueByHotel() async {
    // Try to use the admin view if it exists, otherwise fallback
    try {
      final response = await _client
          .from('admin_revenue_by_hotel')
          .select()
          .order('total_revenue', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (_) {
      return [];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getRevenueOverTime({int days = 30}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final payments = await _client
        .from('payments')
        .select('amount, paid_at')
        .eq('status', 'completed')
        .gte('paid_at', startDate.toIso8601String())
        .order('paid_at');
    return List<Map<String, dynamic>>.from(payments);
  }

  @override
  Future<List<Map<String, dynamic>>> getBookingsOverTime({int days = 30}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final reservations = await _client
        .from('reservations')
        .select('id, created_at, status')
        .gte('created_at', startDate.toIso8601String())
        .order('created_at');
    return List<Map<String, dynamic>>.from(reservations);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserGrowth({int days = 30}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));
    final users = await _client
        .from('profiles')
        .select('id, created_at')
        .gte('created_at', startDate.toIso8601String())
        .order('created_at');
    return List<Map<String, dynamic>>.from(users);
  }

  @override
  Future<List<Map<String, dynamic>>> getPaymentMethodBreakdown() async {
    final payments = await _client
        .from('payments')
        .select('provider, amount')
        .eq('status', 'completed');
    return List<Map<String, dynamic>>.from(payments);
  }

  @override
  Future<List<Map<String, dynamic>>> getTopRooms({int limit = 10}) async {
    // Aggregate from reservations
    final reservations = await _client
        .from('reservations')
        .select('room_id, total_price, rooms(name, hotels(name))')
        .eq('status', 'completed')
        .order('total_price', ascending: false)
        .limit(limit);
    return List<Map<String, dynamic>>.from(reservations);
  }
}
