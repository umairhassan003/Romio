import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// A lightweight animated shimmer placeholder (no external package). A soft
/// highlight sweeps across a base surface — used while images load so the UI
/// feels alive instead of showing a flat colour.
class ShimmerBox extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const ShimmerBox({super.key, this.width, this.height, this.borderRadius});

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1300))..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const base = AppColors.surfaceLight;
    final highlight = Colors.white.withValues(alpha: 0.65);
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [base, highlight, base],
              stops: const [0.1, 0.3, 0.5],
              transform: _SlideGradient(_controller.value * 2 - 1),
            ),
          ),
        );
      },
    );
  }
}

/// Slides the gradient horizontally from off-screen left to off-screen right.
class _SlideGradient extends GradientTransform {
  final double slide; // -1 .. 1
  const _SlideGradient(this.slide);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slide, 0, 0);
  }
}
