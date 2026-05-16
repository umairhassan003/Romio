import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/kpi_card.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../providers/room_admin_provider.dart';

class RoomDetailScreen extends StatefulWidget {
  final String id;
  const RoomDetailScreen({super.key, required this.id});

  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RoomAdminProvider>().loadRoomById(widget.id);
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
    final provider = context.watch<RoomAdminProvider>();
    final room = provider.selectedRoom;
    final l = AppLocalizations.of(context)!;

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy));
    }
    if (room == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bed_outlined, size: 64, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(provider.error ?? l.roomNotFound,
                style: const TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    final imageCount = room.images?.length ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/admin/rooms'),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  room.name,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              StatusBadge(status: room.status),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () => context.go('/admin/rooms/${room.id}/edit'),
                icon: const Icon(Icons.edit, size: 16),
                label: Text(l.adminEditButton),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () async {
                  final confirmed = await ConfirmDialog.show(
                    context: context,
                    title: l.roomDeleteTitle,
                    message: l.roomDeleteMessage,
                    isDangerous: true,
                    confirmLabel: l.adminDeleteButton,
                  );
                  if (confirmed == true && context.mounted) {
                    await provider.deleteRoom(room.id);
                    if (context.mounted) context.go('/admin/rooms');
                  }
                },
                icon: const Icon(Icons.delete, size: 16, color: AppColors.error),
                label: Text(l.adminDeleteButton, style: const TextStyle(color: AppColors.error)),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // KPI Stats
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
                  KpiCard(icon: Icons.attach_money, label: l.roomDetailPriceH, value: '\$${room.pricePerHour.toStringAsFixed(2)}'),
                  KpiCard(icon: Icons.star, label: l.roomDetailRating, value: room.rating.toStringAsFixed(1)),
                  KpiCard(icon: Icons.image, label: l.roomDetailImages, value: '$imageCount'),
                  KpiCard(icon: Icons.wifi, label: 'Amenities', value: '${room.amenities?.length ?? 0}'),
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
                  SectionHeader(title: l.roomDetailInfo),
                  _InfoRow(label: l.roomDetailHotelId, value: room.hotelId),
                  if (room.description != null)
                    _InfoRow(label: l.roomDetailDescription, value: room.description!),
                  _InfoRow(label: l.roomDetailStatus, value: room.status),
                  _InfoRow(label: l.roomDetailCreated, value: room.createdAt.toString().split('.')[0]),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cover Image
          if (room.coverImageUrl != null && room.coverImageUrl!.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'Cover Image'),
                    GestureDetector(
                      onTap: () => _showImageLightbox(room.coverImageUrl!),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            room.coverImageUrl!,
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
          if (room.images != null && room.images!.isNotEmpty) ...[
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
                            'Gallery',
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
                          itemCount: room.images!.length,
                          itemBuilder: (context, index) {
                            final img = room.images![index];
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
          if (room.amenities != null && room.amenities!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeader(title: 'Amenities'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: room.amenities!.map((a) {
                        return Chip(
                          label: Text(a.name),
                          avatar: a.iconKey != null ? const Icon(Icons.check, size: 16) : null,
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
      cursor: SystemMouseCursors.click,
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
