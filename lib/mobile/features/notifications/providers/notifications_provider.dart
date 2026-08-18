import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/models/app_notification.dart';

/// Holds the in-app notification list for the signed-in user and persists it
/// locally (per profile) via SharedPreferences, mirroring how the card wallet
/// is scoped per account. Entries store a type + structured data so their text
/// is localized at display time, honoring the user's current language.
class NotificationsProvider extends ChangeNotifier {
  static const String _prefKeyPrefix = 'notifications_';

  String? _userId;
  List<AppNotification> _items = [];

  /// Newest first.
  List<AppNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.read).length;

  bool get hasUnread => unreadCount > 0;

  String _keyFor(String userId) => '$_prefKeyPrefix$userId';

  /// Loads the stored notifications for [userId]. No-op if already loaded for
  /// the same user.
  Future<void> loadForUser(String userId) async {
    if (_userId == userId && _items.isNotEmpty) return;
    _userId = userId;
    await _readFromDisk();
    notifyListeners();
  }

  Future<void> _readFromDisk() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyFor(_userId!));
      if (raw == null || raw.isEmpty) {
        _items = [];
        return;
      }
      final decoded = jsonDecode(raw) as List;
      _items = decoded
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      debugPrint('NotificationsProvider load failed: $e');
      _items = [];
    }
  }

  Future<void> _persist() async {
    if (_userId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = jsonEncode(_items.map((e) => e.toJson()).toList());
      await prefs.setString(_keyFor(_userId!), raw);
    } catch (e) {
      debugPrint('NotificationsProvider persist failed: $e');
    }
  }

  /// Adds a "booking confirmed" notification for [userId]. If the provider was
  /// not yet loaded for this user (e.g. the flow reached confirmation before the
  /// home screen loaded), it loads first so nothing is lost.
  Future<void> addBookingConfirmed({
    required String userId,
    required String code,
    required String hotelName,
    required String roomName,
    required String reservationDateIso,
    required String checkInTime,
  }) async {
    if (_userId != userId) {
      _userId = userId;
      await _readFromDisk();
    }
    final notification = AppNotification(
      id: 'booking_${code}_${DateTime.now().millisecondsSinceEpoch}',
      type: AppNotificationType.bookingConfirmed,
      createdAt: DateTime.now(),
      data: {
        'code': code,
        'hotel': hotelName,
        'room': roomName,
        'dateIso': reservationDateIso,
        'checkIn': checkInTime,
      },
    );
    _items = [notification, ..._items];
    notifyListeners();
    await _persist();
  }

  /// Removes a single notification (swipe-to-delete). This is the only way an
  /// entry leaves the list — notifications otherwise persist across sessions.
  Future<void> remove(String id) async {
    final before = _items.length;
    _items = _items.where((n) => n.id != id).toList();
    if (_items.length == before) return;
    notifyListeners();
    await _persist();
  }

  /// Marks every notification as read.
  Future<void> markAllRead() async {
    if (_items.every((n) => n.read)) return;
    _items = _items.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
    await _persist();
  }

  /// Clears the list on sign-out so a different account never sees them.
  void clear() {
    _userId = null;
    _items = [];
    notifyListeners();
  }
}
