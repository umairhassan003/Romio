import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../../reservation/providers/reservation_flow_provider.dart';
import '../../../widgets/image_carousel.dart';
import '../../../widgets/amenities_grid.dart';
import '../../../../domain/models/room.dart';
import '../../../../domain/models/amenity.dart';

class RoomDetailScreen extends StatefulWidget {
  final String hotelId;
  final String roomId;
  const RoomDetailScreen({super.key, required this.hotelId, required this.roomId});
  @override
  State<RoomDetailScreen> createState() => _RoomDetailScreenState();
}

class _RoomDetailScreenState extends State<RoomDetailScreen> {
  Room? _room;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRoom();
  }

  Future<void> _loadRoom() async {
    final hp = context.read<HomeProvider>();
    // Try cache first
    var room = hp.getRoomByIds(widget.hotelId, widget.roomId);
    room ??= await hp.fetchRoomDetail(widget.roomId);
    if (mounted) setState(() { _room = room; _loading = false; });
  }

  IconData _amenityIcon(String key) {
    switch (key.toLowerCase()) {
      case 'wifi': return Icons.wifi;
      case 'parking': return Icons.local_parking;
      case 'ac': case 'air_conditioning': return Icons.ac_unit;
      case 'king_bed': case 'king bed': return Icons.king_bed;
      case 'water_heater': case 'water heater': return Icons.water_drop;
      case 'jacuzzi': case 'hot_tub': return Icons.hot_tub;
      default: return Icons.check_circle_outline;
    }
  }

  /// Ordered, de-duplicated list of image URLs: cover first, then gallery.
  List<String> _imageUrls(Room room) {
    final urls = <String>[];
    if (room.coverImageUrl != null && room.coverImageUrl!.isNotEmpty) {
      urls.add(room.coverImageUrl!);
    }
    for (final img in room.images ?? []) {
      if (img.storageUrl.isNotEmpty && !urls.contains(img.storageUrl)) {
        urls.add(img.storageUrl);
      }
    }
    return urls;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hotel = context.read<HomeProvider>().getHotelById(widget.hotelId);

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryBurgundy)),
      );
    }
    if (_room == null) {
      return Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        appBar: AppBar(),
        body: const Center(child: Text('Habitación no encontrada.')),
      );
    }

    final room = _room!;
    final amenities = room.amenities;

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
                imageUrls: _imageUrls(room),
                placeholderIcon: Icons.bed,
                caption: room.name,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.name, style: AppTextStyles.headingL),
                const SizedBox(height: 8),
                Text(hotel?.name ?? '', style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 24),
                Text(l10n?.hotelAboutTitle ?? 'Acerca del hotel', style: AppTextStyles.headingM),
                const SizedBox(height: 8),
                Text(room.description ?? hotel?.description ?? 'Sin descripción.',
                  style: AppTextStyles.bodyM.copyWith(height: 1.5), textAlign: TextAlign.justify),
                const SizedBox(height: 24),
                Text(l10n?.roomDetailAmenitiesTitle ?? 'Servicios en la habitación', style: AppTextStyles.headingM),
                const SizedBox(height: 16),
                AmenitiesGrid(
                  items: _amenityItems(amenities),
                  moreLabel: l10n?.seeMore ?? 'Ver más',
                  lessLabel: l10n?.seeLess ?? 'Ver menos',
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
        ),
        child: SafeArea(
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(l10n?.roomPriceLabel ?? 'Precio', style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
              Text(room.lowestSlotLabel, style: AppTextStyles.price),
            ]),
            ElevatedButton(
              onPressed: () {
                context.read<ReservationFlowProvider>().setRoom(
                  roomId: room.id, roomName: room.name,
                  hotelName: hotel?.name ?? '',
                  price3h: room.price3h,
                  price6h: room.price6h,
                  price24h: room.price24h,
                  payOnProperty: hotel?.payOnProperty ?? false,
                  checkInTime: hotel?.checkInTime,
                );
                context.push('/reservation/${room.id}');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBurgundy,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              ),
              child: Text(l10n?.roomReserveNow ?? 'Reserva Ahora', style: AppTextStyles.labelM.copyWith(color: AppColors.textOnPrimary)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) => Padding(
    padding: const EdgeInsets.all(8),
    child: CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.9),
      child: IconButton(icon: Icon(icon, color: AppColors.primaryBurgundy, size: 20), onPressed: onTap)),
  );

  List<AmenityItem> _amenityItems(List<Amenity>? amenities) {
    if (amenities != null && amenities.isNotEmpty) {
      return amenities
          .map<AmenityItem>((a) => (icon: _amenityIcon(a.iconKey ?? a.name), label: a.name))
          .toList();
    }
    return const [
      (icon: Icons.wifi, label: 'Wifi'),
      (icon: Icons.king_bed, label: 'King Bed'),
      (icon: Icons.ac_unit, label: 'AC'),
      (icon: Icons.water_drop, label: 'Water Heater'),
    ];
  }
}
