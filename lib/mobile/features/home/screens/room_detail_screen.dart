import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/home_provider.dart';
import '../../reservation/providers/reservation_flow_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../../widgets/image_carousel.dart';
import '../../../widgets/amenities_grid.dart';
import '../../../../domain/models/hotel.dart';
import '../../../../domain/models/room.dart';
import '../../../../domain/models/amenity.dart';

class RoomDetailScreen extends StatefulWidget {
  final String hotelId;
  final String roomId;
  const RoomDetailScreen({
    super.key,
    required this.hotelId,
    required this.roomId,
  });

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

    if (room != null && mounted) {
      final hotel = hp.getHotelById(widget.hotelId);
      context.read<ReservationFlowProvider>().setRoom(
        roomId: room.id,
        roomName: room.name,
        hotelName: hotel?.name ?? '',
        hotelAddress: hotel?.address,
        roomImageUrl: room.coverImageUrl,
        price3h: room.price3h,
        price6h: room.price6h,
        price24h: room.price24h,
        paymentMode: hotel?.paymentMode ?? HotelPaymentMode.payAtApp,
        partialPercent3h: hotel?.partialPercent3h,
        partialPercent6h: hotel?.partialPercent6h,
        partialPercent24h: hotel?.partialPercent24h,
        checkInTime: hotel?.checkInTime,
      );
    }

    if (mounted) {
      setState(() {
        _room = room;
        _loading = false;
      });
    }
  }

  IconData _amenityIcon(String key) {
    switch (key.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'parking':
        return Icons.local_parking;
      case 'ac':
      case 'air_conditioning':
        return Icons.ac_unit;
      case 'king_bed':
      case 'king bed':
        return Icons.king_bed;
      case 'water_heater':
      case 'water heater':
        return Icons.water_drop;
      case 'jacuzzi':
      case 'hot_tub':
        return Icons.hot_tub;
      default:
        return Icons.check_circle_outline;
    }
  }

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

  List<AmenityItem> _amenityItems(List<Amenity>? amenities) {
    if (amenities != null && amenities.isNotEmpty) {
      return amenities
          .map<AmenityItem>(
            (a) => (icon: _amenityIcon(a.iconKey ?? a.name), label: a.name),
          )
          .toList();
    }
    return const [
      (icon: Icons.wifi, label: 'Wifi'),
      (icon: Icons.king_bed, label: 'Cama King'),
      (icon: Icons.ac_unit, label: 'AC'),
      (icon: Icons.water_drop, label: 'Agua caliente'),
    ];
  }

  Future<void> _reserveOnProperty(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final provider = context.read<ReservationFlowProvider>();
    final profileId = context.read<ProfileProvider>().profile?.id;
    if (profileId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n?.paymentProfileError ?? 'Error: perfil no cargado',
          ),
        ),
      );
      return;
    }
    final success = await provider.reserveOnProperty(profileId);
    if (success && context.mounted) {
      context.go('/confirmation');
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.error ??
                (l10n?.paymentGenericError ?? 'Error al confirmar'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hotel = context.read<HomeProvider>().getHotelById(widget.hotelId);

    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primaryBurgundy),
        ),
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
    final provider = context.watch<ReservationFlowProvider>();
    final times = provider.availableTimes;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Floating Rounded Image Carousel
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SizedBox(
                      height: 280,
                      child: ImageCarousel(
                        imageUrls: _imageUrls(room),
                        placeholderIcon: Icons.bed,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.9),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primaryBurgundy,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. Room & Hotel Names
              Text(room.name, style: AppTextStyles.headingL),
              const SizedBox(height: 8),
              Text(
                hotel?.name ?? '',
                style: AppTextStyles.bodyM.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // 3. About the Room description
              Text(
                l10n?.localeName == 'es'
                    ? 'Acerca de la habitación'
                    : 'About the Room',
                style: AppTextStyles.headingM,
              ),
              const SizedBox(height: 8),
              Text(
                room.description ?? hotel?.description ?? 'Sin descripción.',
                style: AppTextStyles.bodyM.copyWith(height: 1.5),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 24),

              // 4. Room Amenities
              Text(
                l10n?.roomDetailAmenitiesTitle ?? 'Servicios de la habitación',
                style: AppTextStyles.headingM,
              ),
              const SizedBox(height: 16),
              AmenitiesGrid(
                items: _amenityItems(amenities),
                moreLabel: l10n?.seeMore ?? 'Ver más',
                lessLabel: l10n?.seeLess ?? 'Ver menos',
              ),

              const Divider(
                color: AppColors.borderLight,
                thickness: 1,
                height: 48,
              ),

              // Check-in Time Grid
              Text(
                l10n?.reservationCheckInLabel ?? 'Hora de entrada',
                style: AppTextStyles.headingM,
              ),
              const SizedBox(height: 16),
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 2.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemCount: times.length,
                itemBuilder: (_, i) {
                  final t = times[i];
                  final sel = provider.selectedTime == t;
                  return GestureDetector(
                    onTap: () => provider.setTime(t),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: sel ? AppColors.primaryBurgundy : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color:
                              sel
                                  ? AppColors.primaryBurgundy
                                  : AppColors.textPrimary,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 14,
                            color: sel ? Colors.white : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            t,
                            style: AppTextStyles.labelM.copyWith(
                              color: sel ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // 7. Duration Slots Pill Segmented Control
              Text(
                l10n?.reservationDurationLabel ?? 'Duración (horas)',
                style: AppTextStyles.headingM,
              ),
              const SizedBox(height: 16),
              _buildDurationSelector(context, provider, l10n),
              const SizedBox(height: 32),

              // 8. FAQ Button List Tile
              _buildFaqButton(context, l10n),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: const BoxDecoration(
          color: AppColors.backgroundWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.roomPriceLabel ?? 'Precio',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '\$${provider.totalPrice.toStringAsFixed(0)}',
                          style: AppTextStyles.headingL.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        TextSpan(
                          text:
                              '/${provider.duration} ${l10n?.localeName == 'es' ? 'Horas' : 'Hours'}',
                          style: AppTextStyles.labelM.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed:
                    provider.isLoading
                        ? null
                        : () {
                          // Pay-at-property books without any online payment;
                          // pay-at-app and pay-partial both go to checkout
                          // (which charges the full price or the deposit).
                          if (provider.isPayAtProperty) {
                            _reserveOnProperty(context);
                          } else {
                            context.push('/payment');
                          }
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBurgundy,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child:
                    provider.isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : Text(
                          l10n?.roomReserveNow ?? 'Reserva Ahora',
                          style: AppTextStyles.labelM.copyWith(
                            color: AppColors.textOnPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDurationSelector(
    BuildContext context,
    ReservationFlowProvider provider,
    AppLocalizations? l10n,
  ) {
    final slots = provider.availableSlots;
    if (slots.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children:
            slots.map((hours) {
              final isSelected = provider.duration == hours;
              final label =
                  l10n?.localeName == 'es' ? '$hours horas' : '$hours hours';

              return Expanded(
                child: GestureDetector(
                  onTap: () => provider.selectSlot(hours),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                      boxShadow:
                          isSelected
                              ? [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                              : [],
                    ),
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.labelM.copyWith(
                        color:
                            isSelected
                                ? AppColors.primaryBurgundy
                                : AppColors.textSecondary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildFaqButton(BuildContext context, AppLocalizations? l10n) {
    return InkWell(
      onTap: () => context.push('/profile/faq'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            const Icon(
              Icons.info_outline,
              color: AppColors.textPrimary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              l10n?.profileFaq ?? 'Preguntas frecuentes',
              style: AppTextStyles.labelM.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.textSecondary,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
