import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/hotel.dart';
import '../../domain/repositories/hotel_repository.dart';

class SupabaseHotelRepository implements HotelRepository {
  final SupabaseClient _supabaseClient;
  static const String tableName = 'hotels';

  SupabaseHotelRepository({SupabaseClient? client})
    : _supabaseClient = client ?? Supabase.instance.client;

  // ─── Mobile methods ────────────────────────────────────────────────

  @override
  Future<List<Hotel>> getHotels({int limit = 20, int offset = 0}) async {
    final response = await _supabaseClient
        .from(tableName)
        .select('*, hotel_images(*), hotel_amenities(amenities(*)), rooms(*)')
        .eq('is_active', true)
        .range(offset, offset + limit - 1)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Hotel.fromJson(json)).toList();
  }

  @override
  Future<Hotel?> getHotelById(String id) async {
    final response =
        await _supabaseClient
            .from(tableName)
            .select(
              '*, hotel_images(*), hotel_amenities(amenities(*)), rooms(*)',
            )
            .eq('id', id)
            .maybeSingle();

    if (response == null) return null;
    return Hotel.fromJson(response);
  }

  @override
  Future<List<Hotel>> searchHotels(String query) async {
    final response = await _supabaseClient
        .from(tableName)
        .select('*, hotel_images(*), hotel_amenities(amenities(*)), rooms(*)')
        .eq('is_active', true)
        .ilike('name', '%$query%')
        .order('rating', ascending: false);

    return (response as List).map((json) => Hotel.fromJson(json)).toList();
  }

  // ─── Admin methods ────────────────────────────────────────────────

  @override
  Future<List<Hotel>> getAllHotels({
    int limit = 50,
    int offset = 0,
    bool? isActive,
  }) async {
    var query = _supabaseClient
        .from(tableName)
        .select('*, hotel_images(*), hotel_amenities(amenities(*)), rooms(*)');

    if (isActive != null) {
      query = query.eq('is_active', isActive);
    }

    final response = await query
        .range(offset, offset + limit - 1)
        .order('created_at', ascending: false);

    return (response as List).map((json) => Hotel.fromJson(json)).toList();
  }

  @override
  Future<int> countHotels({bool? isActive}) async {
    var query = _supabaseClient.from(tableName).select('id');
    if (isActive != null) {
      query = query.eq('is_active', isActive);
    }
    final result = await query.count(CountOption.exact);
    return result.count;
  }

  @override
  Future<Hotel> createHotel(Hotel hotel) async {
    final json = hotel.toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');

    final response =
        await _supabaseClient
            .from(tableName)
            .insert(json)
            .select(
              '*, hotel_images(*), hotel_amenities(amenities(*)), rooms(*)',
            )
            .single();

    return Hotel.fromJson(response);
  }

  @override
  Future<Hotel> updateHotel(Hotel hotel) async {
    final json = hotel.toJson();
    json.remove('created_at');
    json['updated_at'] = DateTime.now().toIso8601String();

    final response =
        await _supabaseClient
            .from(tableName)
            .update(json)
            .eq('id', hotel.id)
            .select(
              '*, hotel_images(*), hotel_amenities(amenities(*)), rooms(*)',
            )
            .single();

    return Hotel.fromJson(response);
  }

  @override
  Future<void> toggleActive(String id, bool isActive) async {
    await _supabaseClient
        .from(tableName)
        .update({
          'is_active': isActive,
          'updated_at': DateTime.now().toIso8601String(),
        })
        .eq('id', id);
  }

  @override
  Future<void> deleteHotel(String id) async {
    // 1. Fetch the hotel with its rooms and images
    final hotel = await _supabaseClient
        .from(tableName)
        .select('*, hotel_images(storage_url), rooms(id, cover_image_url)')
        .eq('id', id)
        .maybeSingle();

    if (hotel != null) {
      // 2. Delete all room images (cover + gallery) for each room
      final rooms = hotel['rooms'] as List? ?? [];
      for (final room in rooms) {
        final roomId = room['id'] as String;

        // Delete room gallery images from storage
        final roomImages = await _supabaseClient
            .from('room_images')
            .select('storage_url')
            .eq('room_id', roomId);
        for (final img in roomImages) {
          final url = img['storage_url'] as String? ?? '';
          if (url.isNotEmpty) {
            try {
              final storagePath = _extractStoragePath(url, 'room-images');
              if (storagePath != null) {
                await _supabaseClient.storage.from('room-images').remove([storagePath]);
              }
            } catch (_) {}
          }
        }

        // Delete room cover image from storage
        final roomCover = room['cover_image_url'] as String? ?? '';
        if (roomCover.isNotEmpty) {
          try {
            final storagePath = _extractStoragePath(roomCover, 'room-images');
            if (storagePath != null) {
              await _supabaseClient.storage.from('room-images').remove([storagePath]);
            }
          } catch (_) {}
        }
      }

      // 3. Delete hotel gallery images from storage
      final hotelImages = hotel['hotel_images'] as List? ?? [];
      for (final img in hotelImages) {
        final url = img['storage_url'] as String? ?? '';
        if (url.isNotEmpty) {
          try {
            final storagePath = _extractStoragePath(url, 'hotel-images');
            if (storagePath != null) {
              await _supabaseClient.storage.from('hotel-images').remove([storagePath]);
            }
          } catch (_) {}
        }
      }

      // 4. Delete hotel cover image from storage
      final hotelCover = hotel['cover_image_url'] as String? ?? '';
      if (hotelCover.isNotEmpty) {
        try {
          final storagePath = _extractStoragePath(hotelCover, 'hotel-images');
          if (storagePath != null) {
            await _supabaseClient.storage.from('hotel-images').remove([storagePath]);
          }
        } catch (_) {}
      }
    }

    // 5. Delete the hotel record (DB cascades handle hotel_images, rooms, etc.)
    await _supabaseClient.from(tableName).delete().eq('id', id);
  }

  /// Extract the storage path from a public URL.
  /// Public URLs have the form: .../storage/v1/object/public/[bucket]/[path]
  String? _extractStoragePath(String publicUrl, String bucket) {
    final marker = '/storage/v1/object/public/$bucket/';
    final idx = publicUrl.indexOf(marker);
    if (idx == -1) return null;
    return Uri.decodeFull(publicUrl.substring(idx + marker.length));
  }

  @override
  Future<void> uploadHotelImage(
    String hotelId,
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final path = 'hotels/$hotelId/$fileName';
      await _supabaseClient.storage
          .from('hotel-images')
          .uploadBinary(path, Uint8List.fromList(bytes));
      final publicUrl = _supabaseClient.storage
          .from('hotel-images')
          .getPublicUrl(path);

      // Get current max sort_order
      final existing = await _supabaseClient
          .from('hotel_images')
          .select('sort_order')
          .eq('hotel_id', hotelId)
          .order('sort_order', ascending: false)
          .limit(1);

      final nextOrder =
          existing.isNotEmpty ? (existing[0]['sort_order'] as int) + 1 : 0;

      await _supabaseClient.from('hotel_images').insert({
        'hotel_id': hotelId,
        'storage_url': publicUrl,
        'sort_order': nextOrder,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteHotelImage(String imageId, String storagePath) async {
    await _supabaseClient.from('hotel_images').delete().eq('id', imageId);
    try {
      // storagePath may be a full public URL — extract the relative path
      final relativePath = _extractStoragePath(storagePath, 'hotel-images') ?? storagePath;
      await _supabaseClient.storage.from('hotel-images').remove([relativePath]);
    } catch (_) {
      // Storage deletion is best-effort
    }
  }

  @override
  Future<void> syncHotelAmenities(
    String hotelId,
    List<String> amenityIds,
  ) async {
    // Delete existing
    await _supabaseClient
        .from('hotel_amenities')
        .delete()
        .eq('hotel_id', hotelId);
    // Insert new
    if (amenityIds.isNotEmpty) {
      final rows =
          amenityIds
              .map((id) => {'hotel_id': hotelId, 'amenity_id': id})
              .toList();
      await _supabaseClient.from('hotel_amenities').insert(rows);
    }
  }
}
