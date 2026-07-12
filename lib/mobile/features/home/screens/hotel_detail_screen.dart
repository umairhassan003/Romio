import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../../../widgets/image_carousel.dart';
import '../../../widgets/expandable_text.dart';
import '../../../widgets/amenities_grid.dart';
import '../../../../domain/models/hotel.dart';
import '../../../../domain/models/room.dart';
import '../../../../domain/models/amenity.dart';

class HotelDetailScreen extends StatefulWidget {
  final String hotelId;
  const HotelDetailScreen({super.key, required this.hotelId});
  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  late Future<List<Room>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = context.read<HomeProvider>().getRoomsForHotel(widget.hotelId);
  }

  IconData _amenityIcon(String key) {
    switch (key.toLowerCase()) {
      case 'wifi': return Icons.wifi;
      case 'parking': case 'parking privado': return Icons.local_parking;
      case 'jacuzzi': case 'hot_tub': return Icons.hot_tub;
      case 'ac': case 'air_conditioning': return Icons.ac_unit;
      case 'king_bed': case 'king bed': return Icons.king_bed;
      case 'water_heater': case 'water heater': return Icons.water_drop;
      case 'acceso privado': return Icons.vpn_key;
      default: return Icons.check_circle_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hotel = context.watch<HomeProvider>().getHotelById(widget.hotelId);
    if (hotel == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(),
        body: const Center(child: Text('Hotel no encontrado.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.backgroundWhite,
            leading: _circleBtn(Icons.arrow_back, () => Navigator.pop(context)),
            flexibleSpace: FlexibleSpaceBar(
              background: ImageCarousel(
                imageUrls: _imageUrls(hotel),
                placeholderIcon: Icons.hotel,
                caption: hotel.name,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(hotel.name, style: AppTextStyles.headingL),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(child: Text(hotel.address, style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary))),
                ]),
                const SizedBox(height: 24),
                Text(l10n?.hotelAboutTitle ?? 'Acerca del hotel', style: AppTextStyles.headingM),
                const SizedBox(height: 8),
                ExpandableText(
                  hotel.description ?? 'Sin descripción.',
                  moreLabel: l10n?.seeMore ?? 'Ver más',
                  lessLabel: l10n?.seeLess ?? 'Ver menos',
                ),
                const SizedBox(height: 24),
                Text(l10n?.hotelDetailAmenitiesTitle ?? 'Servicios', style: AppTextStyles.headingM),
                const SizedBox(height: 16),
                AmenitiesGrid(
                  items: _amenityItems(hotel.amenities),
                  moreLabel: l10n?.seeMore ?? 'Ver más',
                  lessLabel: l10n?.seeLess ?? 'Ver menos',
                ),
                const SizedBox(height: 32),
                Text(l10n?.hotelSelectRoom ?? 'Seleccionar habitación', style: AppTextStyles.headingM),
                const SizedBox(height: 16),
                FutureBuilder<List<Room>>(
                  future: _roomsFuture,
                  builder: (ctx, snap) {
                    if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy));
                    final rooms = snap.data ?? [];
                    if (rooms.isEmpty) return const Text('No hay habitaciones disponibles.');
                    return ListView.builder(
                      physics: const NeverScrollableScrollPhysics(), shrinkWrap: true, padding: EdgeInsets.zero,
                      itemCount: rooms.length,
                      itemBuilder: (_, i) => _roomCard(context, rooms[i]),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Ordered, de-duplicated list of image URLs: cover first, then gallery.
  List<String> _imageUrls(Hotel hotel) {
    final urls = <String>[];
    if (hotel.coverImageUrl != null && hotel.coverImageUrl!.isNotEmpty) {
      urls.add(hotel.coverImageUrl!);
    }
    for (final img in hotel.images ?? []) {
      if (img.storageUrl.isNotEmpty && !urls.contains(img.storageUrl)) {
        urls.add(img.storageUrl);
      }
    }
    return urls;
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.all(8),
    child: CircleAvatar(
      backgroundColor: Colors.white.withOpacity(0.9),
      child: IconButton(icon: Icon(icon, color: AppColors.primaryBurgundy, size: 20), onPressed: onTap),
    ),
  );

  List<AmenityItem> _amenityItems(List<Amenity>? amenities) {
    if (amenities != null && amenities.isNotEmpty) {
      return amenities
          .map<AmenityItem>((a) => (icon: _amenityIcon(a.iconKey ?? a.name), label: a.name))
          .toList();
    }
    return const [
      (icon: Icons.wifi, label: 'Wifi'),
      (icon: Icons.local_parking, label: 'Parking Privado'),
      (icon: Icons.vpn_key, label: 'Acceso Privado'),
      (icon: Icons.hot_tub, label: 'Jacuzzi'),
    ];
  }

  Widget _roomCard(BuildContext context, Room room) {
    final amenityText = room.amenities?.isNotEmpty == true ? room.amenities!.take(3).map((a) => '• ${a.name}').join('  ') : '• Wifi  • AC';
    return GestureDetector(
      onTap: () => context.push('/hotel/${widget.hotelId}/room/${room.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.backgroundWhite, borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))]),
        child: Row(children: [
          Container(width: 70, height: 70, clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(12)),
            child: room.coverImageUrl != null ? CachedNetworkImage(imageUrl: room.coverImageUrl!, fit: BoxFit.cover) : const Icon(Icons.bed, color: AppColors.primaryBurgundyLight)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(room.name, style: AppTextStyles.labelM, maxLines: 1, overflow: TextOverflow.ellipsis)),
              Text(room.lowestSlotLabel, style: AppTextStyles.labelM.copyWith(color: AppColors.primaryBurgundy)),
            ]),
            const SizedBox(height: 4),
            Text(amenityText, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
          ])),
        ]),
      ),
    );
  }
}
