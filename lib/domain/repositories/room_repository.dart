import '../models/room.dart';

abstract class RoomRepository {
  // Mobile methods
  Future<List<Room>> getRoomsByHotel(String hotelId);
  Future<Room?> getRoomById(String id);

  // Admin methods
  Future<List<Room>> getAllRooms({int limit = 50, int offset = 0, String? hotelId, String? status});
  Future<int> countRooms({String? hotelId, String? status});
  Future<Room> createRoom(Room room);
  Future<Room> updateRoom(Room room);
  Future<void> updateRoomStatus(String id, String status);
  Future<void> deleteRoom(String id);
  Future<void> uploadRoomImage(String roomId, List<int> bytes, String fileName);
  Future<void> deleteRoomImage(String imageId, String storagePath);
  Future<void> syncRoomAmenities(String roomId, List<String> amenityIds);
}
