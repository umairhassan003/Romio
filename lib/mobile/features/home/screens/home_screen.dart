import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/home_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../features/my_reservations/providers/my_reservations_provider.dart';
import '../../../../domain/models/hotel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _bannerDismissed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<ProfileProvider>().loadProfile(user.id);
        final profile = context.read<ProfileProvider>().profile;
        if (profile != null) {
          context.read<MyReservationsProvider>().loadUserReservations(
            profile.id,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final homeProvider = context.watch<HomeProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final reservationsProvider = context.watch<MyReservationsProvider>();
    final userName = profileProvider.displayName;
    final hasUpcoming = reservationsProvider.upcomingReservations.isNotEmpty;
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());

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
                bottom: false,
                child: RefreshIndicator(
                  color: AppColors.primaryBurgundy,
                  onRefresh: () => homeProvider.loadHotels(),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: 24.0,
                        bottom: 76 + MediaQuery.of(context).viewPadding.bottom,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Header row: greeting + notification bell ─────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${l10n?.homeGreeting ?? '¡Hola'} $userName!',
                                        style: AppTextStyles.labelM.copyWith(
                                          color: AppColors.primaryBurgundyLight,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        l10n?.homeFindHotel ??
                                            'Encuentra tu mejor hotel',
                                        style: AppTextStyles.headingXL,
                                      ),
                                    ],
                                  ),
                                ),
                                // GestureDetector(
                                //   onTap: () {},
                                //   child: Stack(
                                //     children: [
                                //       Container(
                                //         width: 44,
                                //         height: 44,
                                //         decoration: BoxDecoration(
                                //           color: AppColors.surfaceLight,
                                //           shape: BoxShape.circle,
                                //           border: Border.all(
                                //             color: AppColors.borderLight,
                                //           ),
                                //         ),
                                //         child: const Icon(
                                //           Icons.notifications_outlined,
                                //           color: AppColors.primaryBurgundy,
                                //           size: 22,
                                //         ),
                                //       ),
                                //       if (hasUpcoming)
                                //         Positioned(
                                //           top: 8,
                                //           right: 8,
                                //           child: Container(
                                //             width: 8,
                                //             height: 8,
                                //             decoration: const BoxDecoration(
                                //               color: AppColors.error,
                                //               shape: BoxShape.circle,
                                //             ),
                                //           ),
                                //         ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          ),
                          // const SizedBox(height: 20),

                          // ── Search + date row ────────────────────────────
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 24),
                          //   child: Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 16,
                          //       vertical: 12,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: AppColors.backgroundWhite,
                          //       borderRadius: BorderRadius.circular(12),
                          //       border: Border.all(
                          //         color: AppColors.borderLight,
                          //       ),
                          //       boxShadow: [
                          //         BoxShadow(
                          //           color: Colors.black.withValues(alpha: 0.04),
                          //           blurRadius: 6,
                          //           offset: const Offset(0, 2),
                          //         ),
                          //       ],
                          //     ),
                          //     child: Row(
                          //       children: [
                          //         Expanded(
                          //           child: Text(
                          //             l10n?.homeSearchHint ??
                          //                 '¿A dónde quieres ir?',
                          //             style: AppTextStyles.bodyM.copyWith(
                          //               color: AppColors.textSecondary,
                          //             ),
                          //           ),
                          //         ),
                          //         const VerticalDivider(
                          //           width: 24,
                          //           thickness: 1,
                          //           color: AppColors.borderLight,
                          //         ),
                          //         Text(
                          //           today,
                          //           style: AppTextStyles.labelM.copyWith(
                          //             color: AppColors.textPrimary,
                          //           ),
                          //         ),
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          const SizedBox(height: 16),

                          // ── Reservation reminder banner ──────────────────
                          if (hasUpcoming && !_bannerDismissed)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.info.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: AppColors.info.withValues(
                                      alpha: 0.3,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: AppColors.info,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            l10n?.homeNotificationBannerTitle ??
                                                'Tienes una reserva programada',
                                            style: AppTextStyles.labelM,
                                          ),
                                          Text(
                                            l10n?.homeNotificationBannerBody ??
                                                'No olvides tu reserva',
                                            style: AppTextStyles.bodyS.copyWith(
                                              color: AppColors.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap:
                                          () => setState(
                                            () => _bannerDismissed = true,
                                          ),
                                      child: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          if (hasUpcoming && !_bannerDismissed)
                            const SizedBox(height: 16),

                          // ── Recommended section ──────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              l10n?.homeRecommendedTitle ??
                                  'Hoteles recomendados',
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
                                        horizontal: 16,
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

                          // ── All hotels section ───────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              l10n?.homeAllHotelsTitle ?? 'Todos los hoteles',
                              style: AppTextStyles.headingM,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: homeProvider.hotels.length,
                            itemBuilder: (context, index) {
                              return _HotelListCard(
                                hotel: homeProvider.hotels[index],
                                priceLabel: homeProvider
                                    .getMinPriceLabelForHotel(
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
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
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
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.6),
                      ],
                      stops: const [0.4, 1.0],
                    ),
                  ),
                ),
              ),
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
            ? hotel.amenities!.take(2).map((a) => '• ${a.name}').join('  ')
            : '• Wifi  • AC';

    return GestureDetector(
      onTap: () => context.push('/hotel/${hotel.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
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
                          color: AppColors.textPrimary,
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
