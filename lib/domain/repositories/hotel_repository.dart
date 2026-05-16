import '../models/hotel.dart';

abstract class HotelRepository {
  // Mobile-used methods
  Future<List<Hotel>> getHotels({int limit = 20, int offset = 0});
  Future<Hotel?> getHotelById(String id);
  Future<List<Hotel>> searchHotels(String query);

  // Admin methods
  Future<List<Hotel>> getAllHotels({int limit = 50, int offset = 0, bool? isActive});
  Future<int> countHotels({bool? isActive});
  Future<Hotel> createHotel(Hotel hotel);
  Future<Hotel> updateHotel(Hotel hotel);
  Future<void> toggleActive(String id, bool isActive);
  Future<void> deleteHotel(String id);
  Future<void> uploadHotelImage(String hotelId, List<int> bytes, String fileName);
  Future<void> deleteHotelImage(String imageId, String storagePath);
  Future<void> syncHotelAmenities(String hotelId, List<String> amenityIds);
}
