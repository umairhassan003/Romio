import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../data/repositories/supabase_room_repository.dart';
import '../../../../domain/models/room.dart';
import '../../../../domain/models/amenity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RoomAdminProvider extends ChangeNotifier {
  final SupabaseRoomRepository _repo;

  RoomAdminProvider({required SupabaseRoomRepository repo}) : _repo = repo;

  List<Room> rooms = [];
  Room? selectedRoom;
  int totalCount = 0;
  int currentPage = 0;
  int pageSize = 25;
  String? filterHotelId;
  String? filterStatus;
  List<Amenity> availableAmenities = [];

  bool isLoading = false;
  bool isSaving = false;
  bool isUploadingGallery = false;
  String? error;

  Future<void> loadRooms() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      rooms = await _repo.getAllRooms(
        limit: pageSize,
        offset: currentPage * pageSize,
        hotelId: filterHotelId,
        status: filterStatus,
      );
      totalCount = await _repo.countRooms(hotelId: filterHotelId, status: filterStatus);

      final amenitiesRes = await Supabase.instance.client
          .from('amenities')
          .select()
          .inFilter('applies_to', ['room', 'both'])
          .order('name');
      availableAmenities = (amenitiesRes as List).map((a) => Amenity.fromJson(a)).toList();
    } catch (e) {
      error = 'Error al cargar habitaciones: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadRoomById(String id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      selectedRoom = await _repo.getRoomById(id);
    } catch (e) {
      error = 'Error al cargar habitación: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Room?> createRoom(Room room) async {
    isSaving = true; error = null; notifyListeners();
    try {
      final created = await _repo.createRoom(room);
      await loadRooms();
      return created;
    } catch (e) {
      error = 'Error al crear habitación: $e';
      return null;
    } finally {
      isSaving = false; notifyListeners();
    }
  }

  Future<Room?> updateRoom(Room room) async {
    isSaving = true; error = null; notifyListeners();
    try {
      final updated = await _repo.updateRoom(room);
      await loadRooms();
      return updated;
    } catch (e) {
      error = 'Error al actualizar habitación: $e';
      return null;
    } finally {
      isSaving = false; notifyListeners();
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _repo.updateRoomStatus(id, status);
      await loadRooms();
    } catch (e) {
      error = 'Error al cambiar estado: $e';
      notifyListeners();
    }
  }

  Future<void> deleteRoom(String id) async {
    try {
      await _repo.deleteRoom(id);
      await loadRooms();
    } catch (e) {
      error = 'Error al eliminar: $e';
      notifyListeners();
    }
  }

  Future<void> syncAmenities(String roomId, List<String> amenityIds) async {
    try {
      await _repo.syncRoomAmenities(roomId, amenityIds);
    } catch (e) {
      error = 'Error al sincronizar amenidades: $e';
      notifyListeners();
    }
  }

  /// Upload multiple gallery images for a room
  Future<void> uploadGalleryImages(String roomId, List<PlatformFile> files) async {
    isUploadingGallery = true;
    error = null;
    notifyListeners();
    try {
      for (final file in files) {
        if (file.bytes == null) continue;
        final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
        await _repo.uploadRoomImage(roomId, file.bytes!.toList(), fileName);
      }
      // Reload room to get updated images
      await loadRoomById(roomId);
    } catch (e) {
      error = 'Error al subir imágenes: $e';
    } finally {
      isUploadingGallery = false;
      notifyListeners();
    }
  }

  /// Delete a gallery image
  Future<void> deleteGalleryImage(String imageId, String storagePath) async {
    try {
      await _repo.deleteRoomImage(imageId, storagePath);
      // Reload to reflect changes
      if (selectedRoom != null) {
        await loadRoomById(selectedRoom!.id);
      }
    } catch (e) {
      error = 'Error al eliminar imagen: $e';
      notifyListeners();
    }
  }

  void setPage(int page) { currentPage = page; loadRooms(); }
  void setFilterStatus(String? s) { filterStatus = s; currentPage = 0; loadRooms(); }
  void setFilterHotel(String? id) { filterHotelId = id; currentPage = 0; loadRooms(); }
}

