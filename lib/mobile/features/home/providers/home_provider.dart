import 'package:flutter/foundation.dart';
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
  
  final Map<String, List<Room>> _roomsByHotelId = {};

  HomeProvider({
    required HotelRepository hotelRepository,
    required RoomRepository roomRepository,
  })  : _hotelRepository = hotelRepository,
        _roomRepository = roomRepository;

  List<Hotel> get hotels => _hotels;
  bool get isLoading => _isLoading;
  String? get error => _error;

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

  /// Get the minimum price for a hotel from its rooms.
  double getMinPriceForHotel(Hotel hotel) {
    if (hotel.rooms != null && hotel.rooms!.isNotEmpty) {
      return hotel.rooms!.map((r) => r.pricePerHour).reduce((a, b) => a < b ? a : b);
    }
    // Fallback: check cached rooms
    final cached = _roomsByHotelId[hotel.id];
    if (cached != null && cached.isNotEmpty) {
      return cached.map((r) => r.pricePerHour).reduce((a, b) => a < b ? a : b);
    }
    return 50.0; // Default
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
