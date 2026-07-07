import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/models/hotel.dart';
import '../../../../domain/models/amenity.dart';
import '../../../../domain/models/hotel_image.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/error_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/form_field_label.dart';
import '../../../core/widgets/address_autocomplete.dart';
import '../../../core/widgets/amenity_multi_select.dart';
import '../providers/hotel_admin_provider.dart';

class HotelFormScreen extends StatefulWidget {
  final String? hotelId;
  const HotelFormScreen({super.key, this.hotelId});

  @override
  State<HotelFormScreen> createState() => _HotelFormScreenState();
}

class _HotelFormScreenState extends State<HotelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lngCtrl = TextEditingController();

  String? _coverUrl;
  bool _isActive = true;
  bool _payOnProperty = false;
  bool _isEdit = false;
  Hotel? _existingHotel;
  List<Amenity> _selectedAmenities = [];
  bool _isUploadingImage = false;

  // Gallery images state
  List<HotelImage> _galleryImages = [];
  List<PlatformFile> _pendingGalleryFiles = [];
  bool _isUploadingGallery = false;

  @override
  void initState() {
    super.initState();
    if (widget.hotelId != null) {
      _isEdit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final provider = context.read<HotelAdminProvider>();
        await provider.loadHotelById(widget.hotelId!);
        final hotel = provider.selectedHotel;
        if (hotel != null) {
          _existingHotel = hotel;
          _nameCtrl.text = hotel.name;
          _descCtrl.text = hotel.description ?? '';
          _addressCtrl.text = hotel.address;
          _cityCtrl.text = hotel.city ?? '';
          _latCtrl.text = hotel.latitude?.toString() ?? '';
          _lngCtrl.text = hotel.longitude?.toString() ?? '';
          _coverUrl = hotel.coverImageUrl;
          _isActive = hotel.isActive;
          _payOnProperty = hotel.payOnProperty;
          _selectedAmenities = hotel.amenities ?? [];
          _galleryImages = hotel.images ?? [];
          setState(() {});
        }
      });
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _addressCtrl.dispose();
    _cityCtrl.dispose();
    _latCtrl.dispose();
    _lngCtrl.dispose();
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
      final storage = Supabase.instance.client.storage.from('hotel-images');

      // Delete old cover image from storage if it exists
      if (_coverUrl != null && _coverUrl!.isNotEmpty) {
        try {
          final oldPath = _extractStoragePath(_coverUrl!, 'hotel-images');
          if (oldPath != null) {
            await storage.remove([oldPath]);
          }
        } catch (_) {}
      }

      final safeName = file.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final fileName = 'hotel_${DateTime.now().millisecondsSinceEpoch}_$safeName';
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
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<HotelAdminProvider>();

    final hotel = Hotel(
      id: _existingHotel?.id ?? '',
      name: _nameCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      address: _addressCtrl.text.trim(),
      city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
      latitude: double.tryParse(_latCtrl.text),
      longitude: double.tryParse(_lngCtrl.text),
      coverImageUrl: _coverUrl,
      isActive: _isActive,
      payOnProperty: _payOnProperty,
      rating: _existingHotel?.rating ?? 0.0,
      createdAt: _existingHotel?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    Hotel? result;
    if (_isEdit) {
      result = await provider.updateHotel(hotel);
    } else {
      result = await provider.createHotel(hotel);
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

      if (mounted) context.go('/admin/hotels/${result.id}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelAdminProvider>();
    final l = AppLocalizations.of(context)!;

    return LoadingOverlay(
      isLoading: provider.isSaving || _isUploadingGallery,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Back + title
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => context.go('/admin/hotels'),
                ),
                const SizedBox(width: 8),
                Text(
                  _isEdit ? l.hotelFormEditTitle : l.hotelFormNewTitle,
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
                        SectionHeader(title: l.hotelFormGeneralInfo),

                        FormFieldLabel(
                          label: l.hotelFormName,
                          isRequired: true,
                        ),
                        TextFormField(
                          controller: _nameCtrl,
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? l.hotelFormRequired
                                      : null,
                          decoration: InputDecoration(
                            hintText: l.hotelFormNameHint,
                          ),
                        ),
                        const SizedBox(height: 16),

                        FormFieldLabel(label: l.hotelFormDescription),
                        TextFormField(
                          controller: _descCtrl,
                          maxLines: 3,
                          decoration: InputDecoration(
                            hintText: l.hotelFormDescHint,
                          ),
                        ),
                        const SizedBox(height: 16),

                        FormFieldLabel(
                          label: l.hotelFormAddress,
                          isRequired: true,
                        ),
                        AddressAutocomplete(
                          hintText: l.hotelFormAddress,
                          initialValue: _addressCtrl.text,
                          validator:
                              (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? l.hotelFormRequired
                                      : null,
                          onSelected: (suggestion) {
                            _addressCtrl.text = suggestion.address;
                            _cityCtrl.text = suggestion.city;
                            _latCtrl.text = suggestion.latitude.toString();
                            _lngCtrl.text = suggestion.longitude.toString();
                          },
                        ),
                        const SizedBox(height: 16),

                        FormFieldLabel(label: l.hotelFormCity),
                        TextFormField(controller: _cityCtrl),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormFieldLabel(label: l.hotelFormLatitude),
                                  TextFormField(
                                    controller: _latCtrl,
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  FormFieldLabel(label: l.hotelFormLongitude),
                                  TextFormField(
                                    controller: _lngCtrl,
                                    keyboardType: TextInputType.number,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        SectionHeader(title: 'Amenities'),
                        AmenityMultiSelect(
                          title: 'Select Hotel Amenities',
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

                        // ─── Cover Image ──────────────────────────────────
                        SectionHeader(title: l.hotelFormImageStatus),

                        FormFieldLabel(label: l.hotelFormCoverUrl),
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

                        // ─── Gallery Images ──────────────────────────────
                        SectionHeader(title: 'Gallery Images'),
                        const SizedBox(height: 8),
                        Text(
                          'Upload multiple images to showcase the hotel. These will appear in the hotel gallery.',
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
                                        final provider = context.read<HotelAdminProvider>();
                                        provider.deleteGalleryImage(img.id, img.storageUrl);
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

                        const SizedBox(height: 16),

                        SwitchListTile(
                          value: _isActive,
                          onChanged: (v) => setState(() => _isActive = v),
                          title: Text(l.hotelFormActiveSwitch),
                          subtitle: Text(l.hotelFormActiveSubtitle),
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primaryBurgundy,
                        ),

                        SwitchListTile(
                          value: _payOnProperty,
                          onChanged: (v) => setState(() => _payOnProperty = v),
                          title: Text(l.hotelFormPayOnPropertySwitch),
                          subtitle: Text(l.hotelFormPayOnPropertySubtitle),
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primaryBurgundy,
                        ),

                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.go('/admin/hotels'),
                              child: Text(l.adminCancelButton),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton(
                              onPressed: _handleSave,
                              child: Text(
                                _isEdit ? l.hotelFormUpdate : l.hotelFormCreate,
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
