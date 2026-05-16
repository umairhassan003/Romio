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
  
  final Map<String, List<Room>> _roomsByHotelId = {};

  HomeProvider({
    required HotelRepository hotelRepository,
    required RoomRepository roomRepository,
  })  : _hotelRepository = hotelRepository,
        _roomRepository = roomRepository;

  List<Hotel> get hotels => _hotels;
  bool get isLoading => _isLoading;

  Future<void> loadHotels() async {
    _isLoading = true;
    notifyListeners();

    try {
      _hotels = await _hotelRepository.getHotels();
    } catch (e) {
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
}
