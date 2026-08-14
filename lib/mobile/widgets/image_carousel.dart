import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import 'shimmer_box.dart';

/// A swipeable image slider with page-indicator dots.
///
/// * Pages slide in/out directionally as you swipe (with a subtle depth fade).
/// * Tapping any image opens a full-screen, swipeable gallery. Tap anywhere or
///   the close (✕) button to dismiss it.
/// * While an image loads, the Romio logo is shown over a shimmer instead of a
///   blank box.
/// * All images are precached when the carousel appears, so after the first
///   view swiping between them is instant (no loading placeholder).
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final IconData placeholderIcon;

  /// Whether tapping an image opens the full-screen gallery. Defaults to true.
  final bool enableFullscreen;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.placeholderIcon = Icons.image,
    this.enableFullscreen = true,
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

  void _openFullscreen(int index) {
    if (!widget.enableFullscreen) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, __, ___) => _FullscreenGallery(
          imageUrls: widget.imageUrls,
          initialIndex: index,
          placeholderIcon: widget.placeholderIcon,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
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
            itemBuilder: (_, i) => GestureDetector(
              onTap: () => _openFullscreen(i),
              child: _SlidePage(
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
          ),

          // Bottom scrim + dots.
          if (urls.length > 1)
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
                child: _Dots(count: urls.length, current: _current),
              ),
            ),
        ],
      ),
    );
  }
}

/// Full-screen, swipeable gallery shown when an image is tapped.
/// Black backdrop, letter-boxed images, animated dots and a close button.
/// Tapping anywhere (or the ✕) dismisses it.
class _FullscreenGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final IconData placeholderIcon;

  const _FullscreenGallery({
    required this.imageUrls,
    required this.initialIndex,
    required this.placeholderIcon,
  });

  @override
  State<_FullscreenGallery> createState() => _FullscreenGalleryState();
}

class _FullscreenGalleryState extends State<_FullscreenGallery> {
  late final PageController _controller;
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).maybePop();

  @override
  Widget build(BuildContext context) {
    final urls = widget.imageUrls;
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        // Tap anywhere (image or the surrounding black area) to close.
        onTap: _close,
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
                child: Center(
                  child: CachedNetworkImage(
                    imageUrl: urls[i],
                    fit: BoxFit.contain,
                    fadeInDuration: const Duration(milliseconds: 200),
                    placeholder: (_, __) => const Center(
                      child: SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Icon(
                      widget.placeholderIcon,
                      size: 64,
                      color: Colors.white24,
                    ),
                  ),
                ),
              ),
            ),

            // Close (✕) button, top-right.
            Positioned(
              top: 0,
              right: 8,
              child: SafeArea(
                child: IconButton(
                  onPressed: _close,
                  icon: const Icon(Icons.close, color: Colors.white, size: 28),
                ),
              ),
            ),

            // Page dots, bottom-centre.
            if (urls.length > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _Dots(count: urls.length, current: _current),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Animated page-indicator dots (active dot is wider).
class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
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
    );
  }
}

/// "Cover" transition: the current image stays pinned in place while the next
/// image slides in over it from the right, progressively covering it until the
/// swipe completes (and the inverse on the way back — the top image slides off
/// to reveal the one beneath).
///
/// A [PageView] normally moves every page together. Here we cancel that shift
/// for any page being left behind (`delta > 0`) so it stays fixed; the incoming
/// page (`delta <= 0`) moves naturally and — being a later index — paints on
/// top, so it covers the pinned page.
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
        var width = 0.0;
        if (controller.hasClients && controller.position.haveDimensions) {
          delta = (controller.page ?? controller.initialPage.toDouble()) - index;
          width = controller.position.viewportDimension;
        }
        // Pin outgoing/underneath pages by undoing PageView's horizontal shift;
        // let the incoming (covering) page move with the swipe.
        final translateX = delta > 0 ? delta * width : 0.0;
        return Transform.translate(offset: Offset(translateX, 0), child: child);
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
