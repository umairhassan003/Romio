import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/room.dart';
import '../../../../domain/models/amenity.dart';
import '../../../../domain/models/room_image.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/form_field_label.dart';
import '../../../core/widgets/amenity_multi_select.dart';
import '../providers/room_admin_provider.dart';
import '../../hotels/providers/hotel_admin_provider.dart';

class RoomFormScreen extends StatefulWidget {
  final String? roomId;
  const RoomFormScreen({super.key, this.roomId});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _price3hCtrl = TextEditingController();
  final _price6hCtrl = TextEditingController();
  final _price24hCtrl = TextEditingController();

  String? _coverUrl;
  String _status = 'available';
  String? _selectedHotelId;
  bool _isEdit = false;
  Room? _existingRoom;
  List<Amenity> _selectedAmenities = [];
  bool _isUploadingImage = false;

  // Gallery images state
  List<RoomImage> _galleryImages = [];
  List<PlatformFile> _pendingGalleryFiles = [];
  bool _isUploadingGallery = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<HotelAdminProvider>().loadHotels();
      if (widget.roomId != null) {
        _isEdit = true;
        final provider = context.read<RoomAdminProvider>();
        await provider.loadRoomById(widget.roomId!);
        final room = provider.selectedRoom;
        if (room != null) {
          _existingRoom = room;
          _nameCtrl.text = room.name;
          _descCtrl.text = room.description ?? '';
          _price3hCtrl.text = room.price3h.toStringAsFixed(2);
          _price6hCtrl.text = room.price6h.toStringAsFixed(2);
          _price24hCtrl.text = room.price24h.toStringAsFixed(2);
          _coverUrl = room.coverImageUrl;
          _status = room.status;
          _selectedHotelId = room.hotelId;
          _selectedAmenities = room.amenities ?? [];
          _galleryImages = room.images ?? [];
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _price3hCtrl.dispose();
    _price6hCtrl.dispose();
    _price24hCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    setState(() => _isUploadingImage = true);

    try {
      final storage = Supabase.instance.client.storage.from('room-images');

      // Delete old cover image from storage if it exists
      if (_coverUrl != null && _coverUrl!.isNotEmpty) {
        try {
          final oldPath = _extractStoragePath(_coverUrl!, 'room-images');
          if (oldPath != null) {
            await storage.remove([oldPath]);
          }
        } catch (_) {}
      }

      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final fileName = 'room_${DateTime.now().millisecondsSinceEpoch}_$safeName';
      await storage.uploadBinary('covers/$fileName', file.bytes!);
      final publicUrl = storage.getPublicUrl('covers/$fileName');

      setState(() => _coverUrl = publicUrl);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading image: $e')));
    } finally {
      setState(() => _isUploadingImage = false);
    }
  }

  /// Extract storage path from a Supabase public URL
  String? _extractStoragePath(String publicUrl, String bucket) {
    final marker = '/storage/v1/object/public/$bucket/';
    final idx = publicUrl.indexOf(marker);
    if (idx == -1) return null;
    return Uri.decodeFull(publicUrl.substring(idx + marker.length));
  }

  Future<void> _pickGalleryImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    setState(() {
      _pendingGalleryFiles.addAll(result.files.where((f) => f.bytes != null));
    });
  }

  void _removePendingFile(int index) {
    setState(() {
      _pendingGalleryFiles.removeAt(index);
    });
  }

  Future<void> _handleSave() async {
    final l = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    if (_selectedHotelId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l.roomFormSelectHotel)));
      return;
    }
    final provider = context.read<RoomAdminProvider>();
    final price3h = double.tryParse(_price3hCtrl.text) ?? 0;
    final price6h = double.tryParse(_price6hCtrl.text) ?? 0;
    final price24h = double.tryParse(_price24hCtrl.text) ?? 0;
    final room = Room(
      id: _existingRoom?.id ?? '',
      hotelId: _selectedHotelId!,
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      // Keep the hourly rate consistent with the 3h slot for legacy/min-price use.
      pricePerHour: price3h > 0 ? price3h / 3 : (_existingRoom?.pricePerHour ?? 0),
      price3h: price3h,
      price6h: price6h,
      price24h: price24h,
      rating: _existingRoom?.rating ?? 0.0,
      coverImageUrl: _coverUrl,
      status: _status,
      createdAt: _existingRoom?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Room? result;
    if (_isEdit) {
      result = await provider.updateRoom(room);
    } else {
      result = await provider.createRoom(room);
    }

    if (result != null) {
      final amenityIds = _selectedAmenities.map((a) => a.id).toList();
      await provider.syncAmenities(result.id, amenityIds);

      // Upload pending gallery images
      if (_pendingGalleryFiles.isNotEmpty) {
        setState(() => _isUploadingGallery = true);
        await provider.uploadGalleryImages(result.id, _pendingGalleryFiles);
        setState(() => _isUploadingGallery = false);
      }

      if (mounted) context.go('/admin/rooms/${result.id}');
    }
  }

  Widget _priceField(String label, TextEditingController ctrl, AppLocalizations l) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormFieldLabel(label: label, isRequired: true),
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(prefixText: '\$ '),
          validator: (v) {
            final parsed = double.tryParse(v ?? '');
            if (parsed == null || parsed <= 0) return l.roomFormRequired;
            return null;
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoomAdminProvider>();
    final hotelProvider = context.watch<HotelAdminProvider>();
    final l = AppLocalizations.of(context)!;

    return LoadingOverlay(
      isLoading: provider.isSaving || _isUploadingGallery,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/admin/rooms'),
                ),
                const SizedBox(width: 8),
                Text(
                  _isEdit ? l.roomFormEditTitle : l.roomFormNewTitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (provider.error != null) ErrorBanner(message: provider.error!),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Form(
                key: _formKey,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: l.roomFormInfo),
                        FormFieldLabel(
                          label: l.roomFormHotel,
                          isRequired: true,
                        ),
                        DropdownButtonFormField<String>(
                          value: _selectedHotelId,
                          decoration: InputDecoration(
                            hintText: l.roomFormSelectHotel,
                          ),
                          items:
                              hotelProvider.hotels
                                  .map(
                                    (h) => DropdownMenuItem(
                                      value: h.id,
                                      child: Text(h.name),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (v) => setState(() => _selectedHotelId = v),
                          validator:
                              (v) => v == null ? l.roomFormRequired : null,
                        ),
                        const SizedBox(height: 16),
                        FormFieldLabel(label: l.roomFormName, isRequired: true),
                        TextFormField(
                          controller: _nameCtrl,
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? l.roomFormRequired
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        FormFieldLabel(label: l.roomFormDescription),
                        TextFormField(controller: _descCtrl, maxLines: 3),
                        const SizedBox(height: 16),
                        FormFieldLabel(label: l.roomFormStatus),
                        DropdownButtonFormField<String>(
                          value: _status,
                          items: [
                            DropdownMenuItem(
                              value: 'available',
                              child: Text(l.roomFormAvailable),
                            ),
                            DropdownMenuItem(
                              value: 'maintenance',
                              child: Text(l.roomFormMaintenance),
                            ),
                          ],
                          onChanged:
                              (v) => setState(() => _status = v ?? 'available'),
                        ),
                        const SizedBox(height: 24),

                        // ─── Slot pricing (3h / 6h / 24h) ──────────────
                        SectionHeader(title: 'Slot Pricing'),
                        const SizedBox(height: 4),
                        const Text(
                          'Set the price for each booking slot. These are the prices guests pay in the mobile app.',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _priceField('Price — 3 hours', _price3hCtrl, l)),
                            const SizedBox(width: 16),
                            Expanded(child: _priceField('Price — 6 hours', _price6hCtrl, l)),
                            const SizedBox(width: 16),
                            Expanded(child: _priceField('Price — 24 hours', _price24hCtrl, l)),
                          ],
                        ),
                        const SizedBox(height: 24),

                        SectionHeader(title: 'Amenities'),
                        AmenityMultiSelect(
                          title: 'Select Room Amenities',
                          placeholder: 'Tap to select amenities',
                          availableAmenities: provider.availableAmenities,
                          initialSelectedAmenities: _selectedAmenities,
                          onSelectionChanged: (amenities) {
                            setState(() {
                              _selectedAmenities = amenities;
                            });
                          },
                        ),
                        const SizedBox(height: 24),

                        // ─── Cover Image ──────────────────────────────
                        SectionHeader(title: l.roomFormCoverUrl),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_coverUrl != null && _coverUrl!.isNotEmpty)
                              Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: NetworkImage(_coverUrl!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                            else
                              Container(
                                width: 100,
                                height: 100,
                                margin: const EdgeInsets.only(right: 16),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceLight,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.image_outlined,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed:
                                        _isUploadingImage
                                            ? null
                                            : _pickAndUploadImage,
                                    icon:
                                        _isUploadingImage
                                            ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                            : const Icon(Icons.upload_file),
                                    label: Text(
                                      _isUploadingImage
                                          ? 'Uploading...'
                                          : 'Upload Cover Image',
                                    ),
                                  ),
                                  if (_coverUrl != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        _coverUrl!,
                                        style: const TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 12,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ─── Gallery Images ──────────────────────────
                        SectionHeader(title: 'Gallery Images'),
                        const SizedBox(height: 8),
                        Text(
                          'Upload multiple images to showcase the room. These will appear in the room gallery.',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Existing gallery images (only in edit mode)
                        if (_galleryImages.isNotEmpty) ...[
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _galleryImages.map((img) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      img.storageUrl,
                                      width: 120,
                                      height: 90,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Container(
                                        width: 120,
                                        height: 90,
                                        color: AppColors.surfaceLight,
                                        child: const Icon(Icons.broken_image, size: 24),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () {
                                        final prov = context.read<RoomAdminProvider>();
                                        prov.deleteGalleryImage(img.id, img.storageUrl);
                                        setState(() {
                                          _galleryImages.removeWhere((i) => i.id == img.id);
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Pending files (not yet uploaded)
                        if (_pendingGalleryFiles.isNotEmpty) ...[
                          Text(
                            'Pending uploads (${_pendingGalleryFiles.length} files):',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: List.generate(_pendingGalleryFiles.length, (i) {
                              final file = _pendingGalleryFiles[i];
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.memory(
                                      Uint8List.fromList(file.bytes!),
                                      width: 120,
                                      height: 90,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: InkWell(
                                      onTap: () => _removePendingFile(i),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black54,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(Icons.close, color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                        ],

                        OutlinedButton.icon(
                          onPressed: _pickGalleryImages,
                          icon: const Icon(Icons.add_photo_alternate_outlined),
                          label: const Text('Add Gallery Images'),
                        ),

                        const SizedBox(height: 24),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go('/admin/rooms'),
                              child: Text(l.adminCancelButton),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _handleSave,
                              child: Text(
                                _isEdit ? l.roomFormUpdate : l.roomFormCreate,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
