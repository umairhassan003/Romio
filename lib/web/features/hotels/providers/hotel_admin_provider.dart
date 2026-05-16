import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../data/repositories/supabase_hotel_repository.dart';
import '../../../../domain/models/hotel.dart';
import '../../../../domain/models/amenity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HotelAdminProvider extends ChangeNotifier {
  final SupabaseHotelRepository _repo;

  HotelAdminProvider({required SupabaseHotelRepository repo}) : _repo = repo;

  List<Hotel> hotels = [];
  Hotel? selectedHotel;
  int totalCount = 0;
  int currentPage = 0;
  int pageSize = 25;
  bool? filterActive;
  String searchQuery = '';
  List<Amenity> availableAmenities = [];

  bool isLoading = false;
  bool isSaving = false;
  bool isUploadingGallery = false;
  String? error;

  Future<void> loadHotels() async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final results = await _repo.getAllHotels(
        limit: pageSize,
        offset: currentPage * pageSize,
        isActive: filterActive,
      );
      totalCount = await _repo.countHotels(isActive: filterActive);
      hotels = results;

      // Also load available hotel amenities
      final amenitiesRes = await Supabase.instance.client
          .from('amenities')
          .select()
          .inFilter('applies_to', ['hotel', 'both'])
          .order('name');
      availableAmenities =
          (amenitiesRes as List).map((a) => Amenity.fromJson(a)).toList();
    } catch (e) {
      error = 'Error al cargar hoteles: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadHotelById(String id) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      selectedHotel = await _repo.getHotelById(id);
      if (selectedHotel == null) {
        error = 'Hotel no encontrado';
      }
    } catch (e) {
      error = 'Error al cargar hotel: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<Hotel?> createHotel(Hotel hotel) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final created = await _repo.createHotel(hotel);
      await loadHotels();
      return created;
    } catch (e) {
      error = 'Error al crear hotel: $e';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<Hotel?> updateHotel(Hotel hotel) async {
    isSaving = true;
    error = null;
    notifyListeners();
    try {
      final updated = await _repo.updateHotel(hotel);
      await loadHotels();
      return updated;
    } catch (e) {
      error = 'Error al actualizar hotel: $e';
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<void> toggleActive(String id, bool isActive) async {
    try {
      await _repo.toggleActive(id, isActive);
      await loadHotels();
    } catch (e) {
      error = 'Error al cambiar estado: $e';
      notifyListeners();
    }
  }

  Future<void> deleteHotel(String id) async {
    try {
      await _repo.deleteHotel(id);
      await loadHotels();
    } catch (e) {
      error = 'Error al eliminar hotel: $e';
      notifyListeners();
    }
  }

  Future<void> syncAmenities(String hotelId, List<String> amenityIds) async {
    try {
      await _repo.syncHotelAmenities(hotelId, amenityIds);
    } catch (e) {
      error = 'Error al sincronizar amenidades: $e';
      notifyListeners();
    }
  }

  /// Upload multiple gallery images for a hotel
  Future<void> uploadGalleryImages(
    String hotelId,
    List<PlatformFile> files,
  ) async {
    isUploadingGallery = true;
    error = null;
    notifyListeners();
    try {
      for (final file in files) {
        if (file.bytes == null) continue;
        final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
        final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
        await _repo.uploadHotelImage(hotelId, file.bytes!.toList(), fileName);
      }
      // Reload hotel to get updated images
      await loadHotelById(hotelId);
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
      await _repo.deleteHotelImage(imageId, storagePath);
      // Reload to reflect changes
      if (selectedHotel != null) {
        await loadHotelById(selectedHotel!.id);
      }
    } catch (e) {
      error = 'Error al eliminar imagen: $e';
      notifyListeners();
    }
  }

  void setPage(int page) {
    currentPage = page;
    loadHotels();
  }

  void setFilterActive(bool? active) {
    filterActive = active;
    currentPage = 0;
    loadHotels();
  }
}
