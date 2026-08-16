import 'package:flutter/foundation.dart';
import '../../../../core/utils/geo.dart';
import '../../../../domain/models/hotel.dart';
import '../../../../domain/models/room.dart';
import '../../../../domain/repositories/hotel_repository.dart';
import '../../../../domain/repositories/room_repository.dart';

class HomeProvider extends ChangeNotifier {
  final HotelRepository _hotelRepository;
  final RoomRepository _roomRepository;

  List<Hotel> _hotels = [];
  bool _isLoading = false;
  String? _error;

  // Search state: a place selected in the search bar filters/sorts the lists by
  // proximity; the date is the intended check-in shown in the search bar.
  double? _searchLat;
  double? _searchLng;
  String? _searchLabel;
  DateTime? _searchDate;

  final Map<String, List<Room>> _roomsByHotelId = {};

  HomeProvider({
    required HotelRepository hotelRepository,
    required RoomRepository roomRepository,
  })  : _hotelRepository = hotelRepository,
        _roomRepository = roomRepository;

  List<Hotel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ── Search ────────────────────────────────────────────────────────────────
  String? get searchLabel => _searchLabel;
  DateTime? get searchDate => _searchDate;
  bool get hasLocationFilter => _searchLat != null && _searchLng != null;

  /// Set the searched place; the lists re-sort by distance to it.
  void setSearchLocation({
    required double lat,
    required double lng,
    required String label,
  }) {
    _searchLat = lat;
    _searchLng = lng;
    _searchLabel = label;
    notifyListeners();
  }

  /// Clear the place filter and go back to the default ordering.
  void clearSearchLocation() {
    _searchLat = null;
    _searchLng = null;
    _searchLabel = null;
    notifyListeners();
  }

  void setSearchDate(DateTime date) {
    _searchDate = date;
    notifyListeners();
  }

  /// Hotels to show in the recommended + main lists. When a place is searched,
  /// hotels with coordinates are sorted nearest-first and those without
  /// coordinates are appended (so the list is never empty). Otherwise the full
  /// list in its default order.
  List<Hotel> get displayedHotels {
    if (!hasLocationFilter) return _hotels;
    final withCoords = <Hotel>[];
    final withoutCoords = <Hotel>[];
    for (final h in _hotels) {
      if (h.latitude != null && h.longitude != null) {
        withCoords.add(h);
      } else {
        withoutCoords.add(h);
      }
    }
    withCoords.sort((a, b) => haversineKm(_searchLat!, _searchLng!, a.latitude!, a.longitude!)
        .compareTo(haversineKm(_searchLat!, _searchLng!, b.latitude!, b.longitude!)));
    return [...withCoords, ...withoutCoords];
  }

  /// Quick local lookup by hotel ID.
  Hotel? getHotelById(String id) {
    try {
      return _hotels.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Get a cached room by hotel + room ID.
  Room? getRoomByIds(String hotelId, String roomId) {
    final rooms = _roomsByHotelId[hotelId];
    if (rooms == null) return null;
    try {
      return rooms.firstWhere((r) => r.id == roomId);
    } catch (_) {
      return null;
    }
  }

  /// Lowest configured slot price across all rooms of a hotel.
  double getMinPriceForHotel(Hotel hotel) {
    final prices = <double>[];
    void addRoom(Room r) {
      final p = r.price3h ?? r.price6h ?? r.price24h;
      if (p != null) prices.add(p);
    }
    if (hotel.rooms != null && hotel.rooms!.isNotEmpty) {
      hotel.rooms!.forEach(addRoom);
    } else {
      _roomsByHotelId[hotel.id]?.forEach(addRoom);
    }
    return prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b) : 0.0;
  }

  /// Formatted price label for the cheapest available slot, e.g. "\$50/3 Horas".
  /// Returns an empty string when no rooms have any slot configured.
  String getMinPriceLabelForHotel(Hotel hotel) {
    double? best;
    String slotLabel = '/3 Horas';

    void check(double? price, String label) {
      if (price != null && (best == null || price < best!)) {
        best = price;
        slotLabel = label;
      }
    }

    void checkRoom(Room r) {
      check(r.price3h, '/3 Horas');
      check(r.price6h, '/6 Horas');
      check(r.price24h, '/24 Horas');
    }

    if (hotel.rooms != null && hotel.rooms!.isNotEmpty) {
      hotel.rooms!.forEach(checkRoom);
    } else {
      _roomsByHotelId[hotel.id]?.forEach(checkRoom);
    }

    return best != null ? '\$${best!.toStringAsFixed(0)}$slotLabel' : '';
  }

  Future<void> loadHotels() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _hotels = await _hotelRepository.getHotels();
    } catch (e) {
      _error = e.toString();
      debugPrint('Error loading hotels: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Room>> getRoomsForHotel(String hotelId) async {
    if (_roomsByHotelId.containsKey(hotelId)) {
      return _roomsByHotelId[hotelId]!;
    }
    
    try {
      final rooms = await _roomRepository.getRoomsByHotel(hotelId);
      _roomsByHotelId[hotelId] = rooms;
      notifyListeners();
      return rooms;
    } catch (e) {
      debugPrint('Error loading rooms: $e');
      return [];
    }
  }

  /// Fetch a single room with full detail (amenities, images, hotel name).
  Future<Room?> fetchRoomDetail(String roomId) async {
    try {
      return await _roomRepository.getRoomById(roomId);
    } catch (e) {
      debugPrint('Error fetching room detail: $e');
      return null;
    }
  }
}
