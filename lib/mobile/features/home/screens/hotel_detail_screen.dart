import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/home_provider.dart';
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
        backgroundColor: AppColors.backgroundPink,
        appBar: AppBar(),
        body: const Center(child: Text('Hotel no encontrado.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.backgroundPink,
            leading: _circleBtn(Icons.arrow_back, () => Navigator.pop(context)),
            actions: [_circleBtn(Icons.bookmark_border, () {})],
            flexibleSpace: FlexibleSpaceBar(
              background: hotel.coverImageUrl != null
                  ? CachedNetworkImage(imageUrl: hotel.coverImageUrl!, fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.borderLight),
                      errorWidget: (_, __, ___) => Container(color: AppColors.borderLight))
                  : Container(color: AppColors.borderLight, child: const Icon(Icons.hotel, size: 64, color: AppColors.primaryBurgundyLight)),
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
                  const SizedBox(width: 12),
                  const Icon(Icons.star, color: AppColors.starRating, size: 20),
                  const SizedBox(width: 4),
                  Text(hotel.rating.toStringAsFixed(1), style: AppTextStyles.headingS.copyWith(color: AppColors.starRating)),
                ]),
                const SizedBox(height: 24),
                Text(l10n?.hotelAboutTitle ?? 'Acerca del hotel', style: AppTextStyles.headingM),
                const SizedBox(height: 8),
                Text(hotel.description ?? 'Sin descripción.', style: AppTextStyles.bodyM.copyWith(height: 1.5), textAlign: TextAlign.justify),
                const SizedBox(height: 24),
                Text(l10n?.hotelDetailAmenitiesTitle ?? 'Lo que ofrecemos', style: AppTextStyles.headingM),
                const SizedBox(height: 16),
                _amenityRow(hotel.amenities),
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

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.all(8),
    child: CircleAvatar(
      backgroundColor: Colors.white.withOpacity(0.9),
      child: IconButton(icon: Icon(icon, color: AppColors.primaryBurgundy, size: 20), onPressed: onTap),
    ),
  );

  Widget _amenityRow(List<Amenity>? amenities) {
    final items = amenities != null && amenities.isNotEmpty
        ? amenities.map((a) => _amenityChip(_amenityIcon(a.iconKey ?? a.name), a.name)).toList()
        : [_amenityChip(Icons.wifi, 'Wifi'), _amenityChip(Icons.local_parking, 'Parking\nPrivado'), _amenityChip(Icons.vpn_key, 'Acceso\nPrivado'), _amenityChip(Icons.hot_tub, 'Jacuzzi')];
    return Wrap(spacing: 16, runSpacing: 16, children: items);
  }

  Widget _amenityChip(IconData icon, String label) => Column(children: [
    Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: AppColors.primaryBurgundyLight, size: 28)),
    const SizedBox(height: 6),
    Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
  ]);

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
              Text('\$${room.pricePerHour.toStringAsFixed(0)}/3 Horas', style: AppTextStyles.labelM.copyWith(color: AppColors.primaryBurgundy)),
            ]),
            const SizedBox(height: 4),
            Text(amenityText, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.star, size: 14, color: AppColors.starRating), const SizedBox(width: 2),
              Text(room.rating.toStringAsFixed(1), style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600))]),
          ])),
        ]),
      ),
    );
  }
}
