/// Configuration for transactional notification emails delivered through the
/// `send-email` Supabase Edge Function (guest confirmation + hotel notice).
class NotificationConstants {
  const NotificationConstants._();

  /// Central Romio operations inbox that receives every hotel booking
  /// notification. Hotels have no per-property email in the data model yet, so
  /// the ops team receives the notice and relays it to the property.
  static const String hotelNotificationEmail = 'info@getromio.app';
}
