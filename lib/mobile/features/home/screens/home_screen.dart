import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../../../../domain/models/hotel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final homeProvider = context.watch<HomeProvider>();
    
    // Fallbacks just in case profile isn't cached yet
    final userName = 'Usuario';

    return Scaffold(
      backgroundColor: AppColors.backgroundPink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('¡Hola, $userName!', style: AppTextStyles.headingM),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.primaryBurgundy),
            onPressed: () {},
          )
        ],
      ),
      body: homeProvider.isLoading && homeProvider.hotels.isEmpty 
        ? const Center(child: CircularProgressIndicator()) 
        : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Encuentre su mejor hotel',
                style: AppTextStyles.headingXL,
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                l10n?.homeRecommendedTitle ?? 'Recomendado',
                style: AppTextStyles.headingM,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: homeProvider.hotels.isEmpty
                  ? const Center(child: Text('No hay hoteles disponibles'))
                  // Just treating the first few as recommended for display
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                scrollDirection: Axis.horizontal,
                itemCount: homeProvider.hotels.length > 5 ? 5 : homeProvider.hotels.length,
                itemBuilder: (context, index) {
                  final hotel = homeProvider.hotels[index];
                  return _buildRecommendedCard(context, hotel);
                },
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                l10n?.homeAllHotelsTitle ?? 'Todos los hoteles',
                style: AppTextStyles.headingM,
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: homeProvider.hotels.length,
              itemBuilder: (context, index) {
                final hotel = homeProvider.hotels[index];
                return _buildListCard(context, hotel);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(BuildContext context, Hotel hotel) {
    return GestureDetector(
      onTap: () => context.push('/hotel/${hotel.id}'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: hotel.coverImageUrl != null 
                    ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                        child: Image.network(hotel.coverImageUrl!, fit: BoxFit.cover, width: double.infinity),
                      )
                    : const Center(child: Icon(Icons.hotel, size: 48, color: AppColors.primaryBurgundyLight)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name, style: AppTextStyles.labelM, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          hotel.city ?? hotel.address,
                          style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('\$30 / 3 Horas', style: AppTextStyles.price), // Fallback, could adjust based on hotel.rooms prices if they exist
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: AppColors.starRating),
                          const SizedBox(width: 2),
                          Text(hotel.rating.toStringAsFixed(1), style: AppTextStyles.labelM.copyWith(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, Hotel hotel) {
    return GestureDetector(
      onTap: () => context.push('/hotel/${hotel.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: hotel.coverImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(hotel.coverImageUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.hotel, color: AppColors.primaryBurgundyLight),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(hotel.name, style: AppTextStyles.labelM, maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  // Showing first amenity if it exists
                  Text(hotel.amenities?.isNotEmpty == true ? hotel.amenities!.map((a) => a.name).join(', ') : 'Wifi, Parking...', 
                       style: AppTextStyles.bodyS.copyWith(color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis,),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('\$30 / 3 Horas', style: AppTextStyles.labelM), // Mock price
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: AppColors.starRating),
                          Text(hotel.rating.toStringAsFixed(1), style: AppTextStyles.caption),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
