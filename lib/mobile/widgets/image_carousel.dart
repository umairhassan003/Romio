import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'shimmer_box.dart';

/// A swipeable image slider with page-indicator dots.
///
/// * Pages slide in/out directionally as you swipe (with a subtle depth fade).
/// * An optional [caption] (e.g. the hotel name) shows, semi-transparent, at
///   the bottom centre.
/// * While an image loads, the Romio logo is shown over a shimmer instead of a
///   blank box.
/// * All images are precached when the carousel appears, so after the first
///   view swiping between them is instant (no loading placeholder).
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final IconData placeholderIcon;
  final String? caption;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.placeholderIcon = Icons.image,
    this.caption,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final _controller = PageController();
  int _current = 0;
  bool _precached = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Warm the cache for every image up-front so swiping never re-shows the
    // loading state (and images are ready even before their page is built).
    if (!_precached) {
      _precached = true;
      for (final url in widget.imageUrls) {
        precacheImage(CachedNetworkImageProvider(url), context, onError: (_, __) {});
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;

    if (urls.isEmpty) {
      return Container(
        color: AppColors.borderLight,
        child: Icon(widget.placeholderIcon, size: 64, color: AppColors.primaryBurgundyLight),
      );
    }

    return ColoredBox(
      color: AppColors.surfaceLight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _SlidePage(
              controller: _controller,
              index: i,
              child: CachedNetworkImage(
                imageUrl: urls[i],
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 300),
                placeholder: (_, __) => const _LoadingPlaceholder(),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.surfaceLight,
                  child: Icon(widget.placeholderIcon, size: 64, color: AppColors.primaryBurgundyLight),
                ),
              ),
            ),
          ),

          // Bottom scrim + caption + dots.
          if (widget.caption != null || urls.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.only(top: 48, bottom: 14),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x59000000)], // ~35% black
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.caption != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          widget.caption!,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headingS.copyWith(
                            color: Colors.white.withValues(alpha: 0.88),
                            shadows: const [Shadow(color: Colors.black45, blurRadius: 6)],
                          ),
                        ),
                      ),
                    if (widget.caption != null && urls.length > 1)
                      const SizedBox(height: 8),
                    if (urls.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(urls.length, (i) {
                          final active = i == _current;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            width: active ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: active ? Colors.white : Colors.white.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          );
                        }),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Directional slide: the page follows the swipe (moves out one side while the
/// next moves in from the other) with a subtle scale + fade for depth.
class _SlidePage extends StatelessWidget {
  final PageController controller;
  final int index;
  final Widget child;

  const _SlidePage({required this.controller, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        var delta = 0.0;
        if (controller.hasClients && controller.position.haveDimensions) {
          delta = (controller.page ?? controller.initialPage.toDouble()) - index;
        }
        final d = delta.abs().clamp(0.0, 1.0);
        // Mostly a clean slide (PageView handles the horizontal motion); a
        // small scale + fade makes the outgoing page recede as it leaves.
        final scale = 1 - (d * 0.10);
        final opacity = (1 - (d * 0.55)).clamp(0.35, 1.0);
        return Opacity(opacity: opacity, child: Transform.scale(scale: scale, child: child));
      },
      child: child,
    );
  }
}

/// Loading state: the Romio logo over a shimmer, instead of a blank box.
class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ShimmerBox(),
        Center(
          child: Opacity(
            opacity: 0.65,
            child: SvgPicture.asset(
              'images/RomioLogo.svg',
              width: 96,
              colorFilter: const ColorFilter.mode(AppColors.primaryBurgundyLight, BlendMode.srcIn),
            ),
          ),
        ),
      ],
    );
  }
}
