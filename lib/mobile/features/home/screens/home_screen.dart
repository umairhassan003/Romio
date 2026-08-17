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
import '../../reservation/providers/reservation_flow_provider.dart';
import 'dart:async';
import '../../../../core/services/places_service.dart';
import '../../../widgets/app_calendar.dart';
import '../../../../domain/models/hotel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchController = TextEditingController();
  final _searchFocus = FocusNode();
  final _placesService = PlacesService();
  Timer? _debounce;
  List<PlaceResult> _suggestions = [];
  bool _placesLoading = false;
  bool _showSuggestions = false;

  @override
  void initState() {
    super.initState();
    // Hide the suggestions dropdown shortly after the field loses focus (the
    // delay lets a tap on a suggestion register first).
    _searchFocus.addListener(() {
      if (!_searchFocus.hasFocus) {
        Future.delayed(const Duration(milliseconds: 200), () {
          if (mounted && !_searchFocus.hasFocus) {
            setState(() => _showSuggestions = false);
          }
        });
      }
    });
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
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  /// Debounced Venezuela place lookup as the user types in the search field.
  void _onPlaceQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
        _placesLoading = false;
      });
      return;
    }
    setState(() {
      _showSuggestions = true;
      _placesLoading = true;
    });
    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _placesService.searchVenezuela(value);
      if (!mounted || value != _searchController.text) return;
      setState(() {
        _suggestions = results;
        _placesLoading = false;
      });
    });
  }

  /// Applies a picked place as the proximity filter and collapses the dropdown.
  void _selectPlace(HomeProvider provider, PlaceResult place) {
    provider.setSearchLocation(
      lat: place.latitude,
      lng: place.longitude,
      label: place.label,
    );
    _searchController.text = place.label;
    _searchFocus.unfocus();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
      _placesLoading = false;
    });
  }

  /// Clears the search field and removes the proximity filter.
  void _clearPlace(HomeProvider provider) {
    _debounce?.cancel();
    _searchController.clear();
    _searchFocus.unfocus();
    provider.clearSearchLocation();
    setState(() {
      _suggestions = [];
      _showSuggestions = false;
      _placesLoading = false;
    });
  }

  /// Styled dropdown card of place suggestions shown inline under the search
  /// bar (loading spinner, empty state, or the results list).
  Widget _buildSuggestions(HomeProvider provider, AppLocalizations? l10n) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child:
          _placesLoading && _suggestions.isEmpty
              ? const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.primaryBurgundy,
                    ),
                  ),
                ),
              )
              : _suggestions.isEmpty
              ? Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n?.placeSearchEmpty ?? 'No se encontraron lugares.',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              )
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: _suggestions.length,
                separatorBuilder:
                    (_, __) =>
                        const Divider(height: 1, color: AppColors.borderLight),
                itemBuilder: (context, i) {
                  final place = _suggestions[i];
                  return ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primaryBurgundy,
                      size: 20,
                    ),
                    title: Text(
                      place.label,
                      style: AppTextStyles.labelM,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      place.fullName,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () => _selectPlace(provider, place),
                  );
                },
              ),
    );
  }

  /// Opens the shared calendar bottom sheet to choose the booking date (shared
  /// with the hotel page and the final booking via [ReservationFlowProvider]).
  Future<void> _pickDate(
    BuildContext context,
    ReservationFlowProvider provider,
  ) async {
    final picked = await showAppDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDate: provider.selectedDate,
    );
    if (picked != null) provider.setDate(picked);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final homeProvider = context.watch<HomeProvider>();
    final profileProvider = context.watch<ProfileProvider>();
    final reservationsProvider = context.watch<MyReservationsProvider>();
    final reservationProvider = context.watch<ReservationFlowProvider>();
    final userName = profileProvider.displayName;
    final hasUpcoming = reservationsProvider.upcomingReservations.isNotEmpty;
    // Hotels to show — reordered by proximity when a place is searched.
    final displayed = homeProvider.displayedHotels;

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
                                GestureDetector(
                                  onTap: () {},
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: AppColors.surfaceLight,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: AppColors.borderLight,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.notifications_outlined,
                                          color: AppColors.primaryBurgundy,
                                          size: 22,
                                        ),
                                      ),
                                      if (hasUpcoming)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: AppColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ── Search + date row ────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.backgroundWhite,
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                  color: AppColors.primaryBurgundy,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  // Place entry — inline Venezuela autocomplete
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      focusNode: _searchFocus,
                                      onChanged: _onPlaceQueryChanged,
                                      textInputAction: TextInputAction.search,
                                      style: AppTextStyles.bodyM.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                      decoration: InputDecoration(
                                        isDense: true,
                                        filled: false,
                                        contentPadding: EdgeInsets.zero,
                                        border: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        hintText:
                                            l10n?.homeSearchHint ??
                                            '¿A dónde quieres ir?',
                                        hintStyle: AppTextStyles.bodyM.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (_searchController.text.isNotEmpty ||
                                      homeProvider.hasLocationFilter)
                                    GestureDetector(
                                      onTap: () => _clearPlace(homeProvider),
                                      child: const Padding(
                                        padding: EdgeInsets.only(left: 4),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  Container(
                                    width: 1,
                                    height: 24,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                    ),
                                    color: AppColors.textTertiary, // #B3B3B3
                                  ),
                                  // Date — opens the custom calendar bottom sheet
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: () =>
                                        _pickDate(context, reservationProvider),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(reservationProvider.selectedDate),
                                      style: AppTextStyles.labelM.copyWith(
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // ── Inline autocomplete suggestions ──────────────
                          if (_showSuggestions)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                              child: _buildSuggestions(homeProvider, l10n),
                            ),
                          const SizedBox(height: 16),

                          // ── Reservation reminder banner ──────────────────
                          // if (hasUpcoming && !_bannerDismissed)
                          //   Padding(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 24,
                          //     ),
                          //     child: Container(
                          //       padding: const EdgeInsets.symmetric(
                          //         horizontal: 16,
                          //         vertical: 12,
                          //       ),
                          //       decoration: BoxDecoration(
                          //         color: AppColors.info.withValues(alpha: 0.08),
                          //         borderRadius: BorderRadius.circular(12),
                          //         border: Border.all(
                          //           color: AppColors.info.withValues(
                          //             alpha: 0.3,
                          //           ),
                          //         ),
                          //       ),
                          //       child: Row(
                          //         children: [
                          //           const Icon(
                          //             Icons.info_outline,
                          //             color: AppColors.info,
                          //             size: 20,
                          //           ),
                          //           const SizedBox(width: 12),
                          //           Expanded(
                          //             child: Column(
                          //               crossAxisAlignment:
                          //                   CrossAxisAlignment.start,
                          //               children: [
                          //                 Text(
                          //                   l10n?.homeNotificationBannerTitle ??
                          //                       'Tienes una reserva programada',
                          //                   style: AppTextStyles.labelM,
                          //                 ),
                          //                 Text(
                          //                   l10n?.homeNotificationBannerBody ??
                          //                       'No olvides tu reserva',
                          //                   style: AppTextStyles.bodyS.copyWith(
                          //                     color: AppColors.textSecondary,
                          //                   ),
                          //                 ),
                          //               ],
                          //             ),
                          //           ),
                          //           GestureDetector(
                          //             onTap:
                          //                 () => setState(
                          //                   () => _bannerDismissed = true,
                          //                 ),
                          //             child: const Icon(
                          //               Icons.close,
                          //               size: 16,
                          //               color: AppColors.textSecondary,
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // if (hasUpcoming && !_bannerDismissed)
                          //   const SizedBox(height: 16),

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
                                displayed.isEmpty
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
                                          displayed.length > 5
                                              ? 5
                                              : displayed.length,
                                      itemBuilder: (context, index) {
                                        return _RecommendedCard(
                                          hotel: displayed[index],
                                          priceLabel: homeProvider
                                              .getMinPriceLabelForHotel(
                                                displayed[index],
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
                            itemCount: displayed.length,
                            itemBuilder: (context, index) {
                              return _HotelListCard(
                                hotel: displayed[index],
                                priceLabel: homeProvider
                                    .getMinPriceLabelForHotel(displayed[index]),
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
