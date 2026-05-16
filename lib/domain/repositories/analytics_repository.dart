abstract class AnalyticsRepository {
  Future<Map<String, dynamic>> getDashboardStats();
  Future<List<Map<String, dynamic>>> getRevenueByHotel();
  Future<List<Map<String, dynamic>>> getRevenueOverTime({int days = 30});
  Future<List<Map<String, dynamic>>> getBookingsOverTime({int days = 30});
  Future<List<Map<String, dynamic>>> getUserGrowth({int days = 30});
  Future<List<Map<String, dynamic>>> getPaymentMethodBreakdown();
  Future<List<Map<String, dynamic>>> getTopRooms({int limit = 10});
}
