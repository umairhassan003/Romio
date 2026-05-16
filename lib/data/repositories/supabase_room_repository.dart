import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/room.dart';
import '../../domain/repositories/room_repository.dart';

class SupabaseRoomRepository implements RoomRepository {
  final SupabaseClient _supabaseClient;
  static const String tableName = 'rooms';

  SupabaseRoomRepository({SupabaseClient? client}) 
      : _supabaseClient = client ?? Supabase.instance.client;

  @override
  Future<List<Room>> getRoomsByHotel(String hotelId) async {
    final response = await _supabaseClient
        .from(tableName)
        .select('*, room_images(*)')
        .eq('hotel_id', hotelId)
        .order('created_at', ascending: false);
    return (response as List).map((json) => Room.fromJson(json)).toList();
  }

  @override
  Future<Room?> getRoomById(String id) async {
    final response = await _supabaseClient
        .from(tableName)
        .select('*, room_images(*), room_amenities(amenities(*)), hotels(name)')
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return Room.fromJson(response);
  }

  // ─── Admin methods ─────────────────────────────────────────────

  @override
  Future<List<Room>> getAllRooms({int limit = 50, int offset = 0, String? hotelId, String? status}) async {
    var query = _supabaseClient
        .from(tableName)
        .select('*, room_images(*), hotels(name)');
    if (hotelId != null) query = query.eq('hotel_id', hotelId);
    if (status != null) query = query.eq('status', status);

    final response = await query
        .range(offset, offset + limit - 1)
        .order('created_at', ascending: false);
    return (response as List).map((json) => Room.fromJson(json)).toList();
  }

  @override
  Future<int> countRooms({String? hotelId, String? status}) async {
    var query = _supabaseClient.from(tableName).select('id');
    if (hotelId != null) query = query.eq('hotel_id', hotelId);
    if (status != null) query = query.eq('status', status);
    final result = await query.count(CountOption.exact);
    return result.count;
  }

  @override
  Future<Room> createRoom(Room room) async {
    final json = room.toJson();
    json.remove('id');
    json.remove('created_at');
    json.remove('updated_at');
    final response = await _supabaseClient
        .from(tableName)
        .insert(json)
        .select('*, room_images(*)')
        .single();
    return Room.fromJson(response);
  }

  @override
  Future<Room> updateRoom(Room room) async {
    final json = room.toJson();
    json.remove('created_at');
    json['updated_at'] = DateTime.now().toIso8601String();
    final response = await _supabaseClient
        .from(tableName)
        .update(json)
        .eq('id', room.id)
        .select('*, room_images(*)')
        .single();
    return Room.fromJson(response);
  }

  @override
  Future<void> updateRoomStatus(String id, String status) async {
    await _supabaseClient
        .from(tableName)
        .update({'status': status, 'updated_at': DateTime.now().toIso8601String()})
        .eq('id', id);
  }

  @override
  Future<void> deleteRoom(String id) async {
    // 1. Fetch room data to get cover image URL
    final room = await _supabaseClient
        .from(tableName)
        .select('cover_image_url')
        .eq('id', id)
        .maybeSingle();

    // 2. Delete gallery images from storage
    final galleryImages = await _supabaseClient
        .from('room_images')
        .select('storage_url')
        .eq('room_id', id);
    for (final img in galleryImages) {
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

    // 3. Delete cover image from storage
    if (room != null) {
      final coverUrl = room['cover_image_url'] as String? ?? '';
      if (coverUrl.isNotEmpty) {
        try {
          final storagePath = _extractStoragePath(coverUrl, 'room-images');
          if (storagePath != null) {
            await _supabaseClient.storage.from('room-images').remove([storagePath]);
          }
        } catch (_) {}
      }
    }

    // 4. Delete room record (DB cascades handle room_images, room_amenities)
    await _supabaseClient.from(tableName).delete().eq('id', id);
  }

  /// Extract the storage path from a public URL.
  String? _extractStoragePath(String publicUrl, String bucket) {
    final marker = '/storage/v1/object/public/$bucket/';
    final idx = publicUrl.indexOf(marker);
    if (idx == -1) return null;
    return Uri.decodeFull(publicUrl.substring(idx + marker.length));
  }

  @override
  Future<void> uploadRoomImage(
    String roomId,
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final path = 'rooms/$roomId/$fileName';
      await _supabaseClient.storage
          .from('room-images')
          .uploadBinary(path, Uint8List.fromList(bytes));
      final publicUrl = _supabaseClient.storage
          .from('room-images')
          .getPublicUrl(path);

      // Get current max sort_order
      final existing = await _supabaseClient
          .from('room_images')
          .select('sort_order')
          .eq('room_id', roomId)
          .order('sort_order', ascending: false)
          .limit(1);

      final nextOrder =
          existing.isNotEmpty ? (existing[0]['sort_order'] as int) + 1 : 0;

      await _supabaseClient.from('room_images').insert({
        'room_id': roomId,
        'storage_url': publicUrl,
        'sort_order': nextOrder,
      });
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteRoomImage(String imageId, String storagePath) async {
    await _supabaseClient.from('room_images').delete().eq('id', imageId);
    try {
      // storagePath may be a full public URL — extract the relative path
      final relativePath = _extractStoragePath(storagePath, 'room-images') ?? storagePath;
      await _supabaseClient.storage.from('room-images').remove([relativePath]);
    } catch (_) {
      // Storage deletion is best-effort
    }
  }

  @override
  Future<void> syncRoomAmenities(String roomId, List<String> amenityIds) async {
    await _supabaseClient.from('room_amenities').delete().eq('room_id', roomId);
    if (amenityIds.isNotEmpty) {
      final rows = amenityIds.map((id) => {'room_id': roomId, 'amenity_id': id}).toList();
      await _supabaseClient.from('room_amenities').insert(rows);
    }
  }
}
