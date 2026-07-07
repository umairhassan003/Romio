import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_colors.dart';
import 'shimmer_box.dart';

/// A swipeable image slider with page-indicator dots. Used for hotel and room
/// photo galleries. Pages get a subtle scale/parallax animation as you swipe,
/// and each image shows a shimmer placeholder while it loads.
class ImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final IconData placeholderIcon;

  const ImageCarousel({
    super.key,
    required this.imageUrls,
    this.placeholderIcon = Icons.image,
  });

  @override
  State<ImageCarousel> createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  final _controller = PageController();
  int _current = 0;

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
      // Neutral backdrop shown briefly behind pages mid-swipe (while scaled).
      color: AppColors.surfaceLight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: urls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => _AnimatedPage(
              controller: _controller,
              index: i,
              child: CachedNetworkImage(
                imageUrl: urls[i],
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 350),
                placeholder: (_, __) => const ShimmerBox(),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.borderLight,
                  child: Icon(widget.placeholderIcon, size: 64, color: AppColors.primaryBurgundyLight),
                ),
              ),
            ),
          ),
          if (urls.length > 1)
            Positioned(
              bottom: 12,
              left: 0,
              right: 0,
              child: Row(
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
                      color: active ? AppColors.primaryBurgundy : Colors.white.withValues(alpha: 0.75),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }
}

/// Applies a subtle scale (and slight fade) to a page based on how far it is
/// from the currently-centred page, giving a smooth switching animation.
class _AnimatedPage extends StatelessWidget {
  final PageController controller;
  final int index;
  final Widget child;

  const _AnimatedPage({
    required this.controller,
    required this.index,
    required this.child,
  });

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
        // Pronounced "in / out": the leaving image zooms + fades out, the
        // arriving image zooms up + fades in through the neutral backdrop.
        final scale = 1 - (d * 0.22); // 1.0 (centred) -> 0.78 (fully out)
        final opacity = (1 - (d * 0.85)).clamp(0.15, 1.0);
        return Opacity(
          opacity: opacity,
          child: Transform.scale(
            scale: scale,
            // Slight horizontal drift toward centre for a parallax feel.
            child: Transform.translate(
              offset: Offset(delta * -24, 0),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}
