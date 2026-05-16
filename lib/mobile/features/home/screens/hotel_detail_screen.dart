import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../../../../domain/models/room.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final homeProvider = context.watch<HomeProvider>();

    try {
      final hotel = homeProvider.hotels.firstWhere((h) => h.id == widget.hotelId);

      return Scaffold(
        backgroundColor: AppColors.backgroundPink,
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 250.0,
              pinned: true,
              iconTheme: const IconThemeData(color: AppColors.primaryBurgundy),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border),
                  onPressed: () {},
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                background: hotel.coverImageUrl != null
                    ? Image.network(hotel.coverImageUrl!, fit: BoxFit.cover)
                    : Container(color: AppColors.borderLight),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(hotel.name, style: AppTextStyles.headingL),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.star, color: AppColors.starRating, size: 20),
                            const SizedBox(width: 4),
                            Text(hotel.rating.toStringAsFixed(1), style: AppTextStyles.headingS.copyWith(color: AppColors.starRating)),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(hotel.city ?? hotel.address, style: AppTextStyles.bodyM.copyWith(color: AppColors.textSecondary)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text('Acerca del hotel', style: AppTextStyles.headingM),
                    const SizedBox(height: 8),
                    Text(
                      hotel.description ?? 'Sin descripción.',
                      style: AppTextStyles.bodyM,
                    ),
                    const SizedBox(height: 24),
                    Text(l10n?.hotelDetailAmenitiesTitle ?? 'Lo que ofrecemos', style: AppTextStyles.headingM),
                    const SizedBox(height: 16),
                    hotel.amenities?.isNotEmpty == true
                        ? Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: hotel.amenities!.map((a) {
                              return _buildAmenityIcon(Icons.check_circle_outline, a.name); // Just a generic icon
                            }).toList(),
                          )
                        : Wrap(
                            spacing: 16,
                            runSpacing: 16,
                            children: [
                              _buildAmenityIcon(Icons.wifi, 'Wifi'),
                              _buildAmenityIcon(Icons.local_parking, 'Parking'),
                              _buildAmenityIcon(Icons.hot_tub, 'Jacuzzi'),
                            ],
                          ),
                    const SizedBox(height: 32),
                    const Text('Seleccionar habitación', style: AppTextStyles.headingM),
                    const SizedBox(height: 16),
                    FutureBuilder<List<Room>>(
                      future: _roomsFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return const Text('Error loading rooms');
                        }
                        final rooms = snapshot.data ?? [];
                        if (rooms.isEmpty) {
                          return const Text('No hay habitaciones disponibles.');
                        }
                        return ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.zero,
                          itemCount: rooms.length,
                          itemBuilder: (context, index) {
                            return _buildRoomCard(context, rooms[index]);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      );
    } catch (e) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Hotel no encontrado.')),
      );
    }
  }

  Widget _buildAmenityIcon(IconData icon, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primaryBurgundyLight),
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildRoomCard(BuildContext context, Room room) {
    return GestureDetector(
      onTap: () => context.push('/hotel/${widget.hotelId}/room/${room.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: room.coverImageUrl != null
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Image.network(room.coverImageUrl!, fit: BoxFit.cover, width: double.infinity),
                    )
                  : const Icon(Icons.hotel, color: AppColors.primaryBurgundyLight),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(room.name, style: AppTextStyles.labelM),
                      const SizedBox(height: 4),
                      Text(room.description ?? 'Standard room', style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                  Text('\$${room.pricePerHour} / 1h', style: AppTextStyles.price),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
