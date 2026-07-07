import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../../reservation/providers/reservation_flow_provider.dart';
import '../../../../domain/models/room.dart';

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
    final price = room.pricePerHour;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.backgroundWhite,
            leading: _circleBtn(Icons.arrow_back, () => Navigator.pop(context)),
            actions: [_circleBtn(Icons.bookmark_border, () {})],
            flexibleSpace: FlexibleSpaceBar(
              background: room.coverImageUrl != null
                  ? CachedNetworkImage(imageUrl: room.coverImageUrl!, fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: AppColors.borderLight),
                      errorWidget: (_, __, ___) => Container(color: AppColors.borderLight))
                  : Container(color: AppColors.borderLight, child: const Icon(Icons.bed, size: 64, color: AppColors.primaryBurgundyLight)),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 120),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(room.name, style: AppTextStyles.headingL),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(child: Text(hotel?.name ?? '', style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary))),
                  const Icon(Icons.star, color: AppColors.starRating, size: 20),
                  const SizedBox(width: 4),
                  Text(room.rating.toStringAsFixed(1), style: AppTextStyles.headingS.copyWith(color: AppColors.starRating)),
                ]),
                const SizedBox(height: 24),
                Text(l10n?.hotelAboutTitle ?? 'Acerca del hotel', style: AppTextStyles.headingM),
                const SizedBox(height: 8),
                Text(room.description ?? hotel?.description ?? 'Sin descripción.',
                  style: AppTextStyles.bodyM.copyWith(height: 1.5), textAlign: TextAlign.justify),
                const SizedBox(height: 24),
                Text(l10n?.hotelDetailAmenitiesTitle ?? 'Lo que ofrecemos', style: AppTextStyles.headingM),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16, runSpacing: 16,
                  children: amenities != null && amenities.isNotEmpty
                      ? amenities.map((a) => _chip(_amenityIcon(a.iconKey ?? a.name), a.name)).toList()
                      : [_chip(Icons.wifi, 'Wifi'), _chip(Icons.king_bed, 'King\nBed'), _chip(Icons.ac_unit, 'AC'), _chip(Icons.water_drop, 'Water\nHeater')],
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
              Text('\$${price.toStringAsFixed(0)}/3 Horas', style: AppTextStyles.price),
            ]),
            ElevatedButton(
              onPressed: () {
                context.read<ReservationFlowProvider>().setRoom(
                  roomId: room.id, roomName: room.name,
                  hotelName: hotel?.name ?? '', pricePerHour: price,
                  payOnProperty: hotel?.payOnProperty ?? false,
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
    child: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.9),
      child: IconButton(icon: Icon(icon, color: AppColors.primaryBurgundy, size: 20), onPressed: onTap)),
  );

  Widget _chip(IconData icon, String label) => Column(children: [
    Container(width: 60, height: 60, decoration: BoxDecoration(color: AppColors.surfaceLight, borderRadius: BorderRadius.circular(16)),
      child: Icon(icon, color: AppColors.primaryBurgundyLight, size: 28)),
    const SizedBox(height: 6),
    Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary), textAlign: TextAlign.center),
  ]);
}
