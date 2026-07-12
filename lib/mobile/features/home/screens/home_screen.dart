import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../../domain/models/hotel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<ProfileProvider>().loadProfile(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final homeProvider = context.watch<HomeProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final userName = profileProvider.displayName;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body:
          homeProvider.isLoading && homeProvider.hotels.isEmpty
              ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBurgundy,
                ),
              )
              : SafeArea(
                // Let content scroll *behind* the floating (translucent) nav
                // bar; the content padding below keeps the last hotel clear.
                bottom: false,
                child: RefreshIndicator(
                  color: AppColors.primaryBurgundy,
                  onRefresh: () => homeProvider.loadHotels(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 24.0,
                        // Clear the floating nav bar (its height + gesture inset)
                        // so the last hotel isn't covered at the end of the list.
                        bottom: 76 + MediaQuery.of(context).viewPadding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Greeting ────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              '${l10n?.homeGreeting ?? '¡Hola'}, $userName!',
                              style: AppTextStyles.bodyM.copyWith(
                                color: AppColors.primaryBurgundyLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              l10n?.homeFindHotel ?? 'Encuentre su mejor hotel',
                              style: AppTextStyles.headingXL,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // ── Recommended section ─────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              l10n?.homeRecommendedTitle ?? 'Recomendado',
                              style: AppTextStyles.headingM,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 260,
                            child:
                                homeProvider.hotels.isEmpty
                                    ? Center(
                                      child: Text(
                                        l10n?.homeNoHotels ??
                                            'No hay hoteles disponibles',
                                      ),
                                    )
                                    : ListView.builder(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          homeProvider.hotels.length > 5
                                              ? 5
                                              : homeProvider.hotels.length,
                                      itemBuilder: (context, index) {
                                        return _RecommendedCard(
                                          hotel: homeProvider.hotels[index],
                                          priceLabel: homeProvider
                                              .getMinPriceLabelForHotel(
                                                homeProvider.hotels[index],
                                              ),
                                        );
                                      },
                                    ),
                          ),
                          const SizedBox(height: 28),

                          // ── All hotels section ──────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Text(
                              l10n?.homeAllHotelsTitle ?? 'Todos los hoteles',
                              style: AppTextStyles.headingM,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: homeProvider.hotels.length,
                            itemBuilder: (context, index) {
                              return _HotelListCard(
                                hotel: homeProvider.hotels[index],
                                priceLabel: homeProvider.getMinPriceLabelForHotel(
                                  homeProvider.hotels[index],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
    );
  }
}

// ─── Recommended horizontal card ──────────────────────────────────────────────

class _RecommendedCard extends StatelessWidget {
  final Hotel hotel;
  final String priceLabel;

  const _RecommendedCard({required this.hotel, required this.priceLabel});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/hotel/${hotel.id}'),
      child: Container(
        width: 200,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child:
                    hotel.coverImageUrl != null
                        ? CachedNetworkImage(
                          imageUrl: hotel.coverImageUrl!,
                          fit: BoxFit.cover,
                          placeholder:
                              (_, __) =>
                                  Container(color: AppColors.borderLight),
                          errorWidget:
                              (_, __, ___) => Container(
                                color: AppColors.borderLight,
                                child: const Icon(
                                  Icons.hotel,
                                  size: 48,
                                  color: AppColors.primaryBurgundyLight,
                                ),
                              ),
                        )
                        : Container(
                          color: AppColors.borderLight,
                          child: const Icon(
                            Icons.hotel,
                            size: 48,
                            color: AppColors.primaryBurgundyLight,
                          ),
                        ),
              ),
              // Gradient overlay for text
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
              // Bottom text
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hotel.name,
                      style: AppTextStyles.labelM.copyWith(color: Colors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 12,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  hotel.city ?? hotel.address,
                                  style: AppTextStyles.caption.copyWith(
                                    color: Colors.white70,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (priceLabel.isNotEmpty)
                          Text(
                            priceLabel,
                            style: AppTextStyles.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Hotel list card ──────────────────────────────────────────────────────────

class _HotelListCard extends StatelessWidget {
  final Hotel hotel;
  final String priceLabel;

  const _HotelListCard({required this.hotel, required this.priceLabel});

  @override
  Widget build(BuildContext context) {
    final amenityText =
        hotel.amenities?.isNotEmpty == true
            ? hotel.amenities!.take(3).map((a) => '• ${a.name}').join('  ')
            : '• Wifi  • AC';

    return GestureDetector(
      onTap: () => context.push('/hotel/${hotel.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: AppColors.backgroundPink,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child:
                  hotel.coverImageUrl != null
                      ? CachedNetworkImage(
                        imageUrl: hotel.coverImageUrl!,
                        fit: BoxFit.cover,
                        placeholder:
                            (_, __) => const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                        errorWidget:
                            (_, __, ___) => const Icon(
                              Icons.hotel,
                              color: AppColors.primaryBurgundyLight,
                            ),
                      )
                      : const Icon(
                        Icons.hotel,
                        color: AppColors.primaryBurgundyLight,
                      ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hotel.name,
                    style: AppTextStyles.labelM,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    amenityText,
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          hotel.city ?? hotel.address,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (priceLabel.isNotEmpty)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        priceLabel,
                        style: AppTextStyles.labelM.copyWith(
                          color: AppColors.primaryBurgundy,
                        ),
                      ),
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
