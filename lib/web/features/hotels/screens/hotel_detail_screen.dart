import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/widgets/kpi_card.dart';
import '../providers/hotel_admin_provider.dart';

class HotelDetailScreen extends StatefulWidget {
  final String id;
  const HotelDetailScreen({super.key, required this.id});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HotelAdminProvider>().loadHotelById(widget.id);
    });
  }

  void _showImageLightbox(String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              child: Container(color: Colors.black54),
            ),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(ctx).size.width * 0.85,
                  maxHeight: MediaQuery.of(ctx).size.height * 0.85,
                ),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Container(
                    width: 400,
                    height: 300,
                    color: AppColors.surfaceLight,
                    child: const Center(child: Icon(Icons.broken_image, size: 64)),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                style: IconButton.styleFrom(backgroundColor: Colors.black45),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HotelAdminProvider>();
    final hotel = provider.selectedHotel;
    final l = AppLocalizations.of(context)!;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy));
    }

    if (hotel == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hotel_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(provider.error ?? l.hotelNotFound,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final imageCount = hotel.images?.length ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back + title + actions
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/admin/hotels'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hotel.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(status: hotel.isActive ? 'active' : 'inactive'),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/admin/hotels/${hotel.id}/edit'),
                icon: const Icon(Icons.edit, size: 16),
                label: Text(l.adminEditButton),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    title: l.hotelDeleteTitle,
                    message: l.hotelDeleteMessage(hotel.name),
                    isDangerous: true,
                    confirmLabel: l.adminDeleteButton,
                  );
                  if (confirmed == true && context.mounted) {
                    await provider.deleteHotel(hotel.id);
                    if (context.mounted) context.go('/admin/hotels');
                  }
                },
                icon: const Icon(Icons.delete, size: 16, color: AppColors.error),
                label: Text(l.adminDeleteButton, style: const TextStyle(color: AppColors.error)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Stats row
          LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = constraints.maxWidth > 800 ? 4 : 2;
              return GridView.count(
                crossAxisCount: crossAxisCount,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 2.0,
                children: [
                  KpiCard(icon: Icons.bed, label: l.hotelDetailRooms, value: '${hotel.rooms?.length ?? 0}'),
                  KpiCard(icon: Icons.star, label: l.hotelDetailRating, value: hotel.rating.toStringAsFixed(1)),
                  KpiCard(icon: Icons.image, label: l.hotelDetailImages, value: '$imageCount'),
                  KpiCard(icon: Icons.wifi, label: l.hotelDetailAmenities, value: '${hotel.amenities?.length ?? 0}'),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(title: l.hotelDetailInfo),
                  _InfoRow(label: l.hotelDetailAddress, value: hotel.address),
                  _InfoRow(label: l.hotelDetailCity, value: hotel.city ?? '—'),
                  _InfoRow(label: l.hotelDetailLatitude, value: hotel.latitude?.toString() ?? '—'),
                  _InfoRow(label: l.hotelDetailLongitude, value: hotel.longitude?.toString() ?? '—'),
                  _InfoRow(
                    label: l.hotelDetailPayOnProperty,
                    value: hotel.payOnProperty ? l.adminEnabled : l.adminDisabled,
                  ),
                  if (hotel.description != null && hotel.description!.isNotEmpty) ...[
                    const Divider(),
                    SectionHeader(title: l.hotelDetailDescription),
                    Text(hotel.description!),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cover image
          if (hotel.coverImageUrl != null && hotel.coverImageUrl!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: l.hotelDetailCover),
                    GestureDetector(
                      onTap: () => _showImageLightbox(hotel.coverImageUrl!),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            hotel.coverImageUrl!,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 200,
                              color: AppColors.surfaceLight,
                              child: const Center(child: Icon(Icons.broken_image, size: 48)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Gallery
          if (hotel.images != null && hotel.images!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.hotelDetailGallery,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBurgundy.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '$imageCount ${imageCount == 1 ? 'image' : 'images'}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryBurgundy,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxis = constraints.maxWidth > 900
                            ? 4
                            : constraints.maxWidth > 600
                                ? 3
                                : 2;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxis,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 1.4,
                          ),
                          itemCount: hotel.images!.length,
                          itemBuilder: (context, index) {
                            final img = hotel.images![index];
                            return GestureDetector(
                              onTap: () => _showImageLightbox(img.storageUrl),
                              child: _GalleryTile(imageUrl: img.storageUrl),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Amenities
          if (hotel.amenities != null && hotel.amenities!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: l.hotelDetailAmenities),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: hotel.amenities!.map((a) {
                        return Chip(
                          label: Text(a.name),
                          avatar: a.iconKey != null ? Icon(Icons.check, size: 16) : null,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _GalleryTile extends StatefulWidget {
  final String imageUrl;
  const _GalleryTile({required this.imageUrl});

  @override
  State<_GalleryTile> createState() => _GalleryTileState();
}

class _GalleryTileState extends State<_GalleryTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: AppColors.primaryBurgundy.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                widget.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: AppColors.surfaceLight,
                  child: const Center(child: Icon(Icons.broken_image, size: 32)),
                ),
              ),
              // Hover overlay
              AnimatedOpacity(
                opacity: _isHovered ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.4),
                      ],
                    ),
                  ),
                  alignment: Alignment.bottomCenter,
                  padding: const EdgeInsets.all(8),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.zoom_in, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'View',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }
}
