import 'package:material_ui/material_ui.dart';

import '../theme/app_colors.dart';

/// Widget shimmer skeleton murni Flutter (zero-dependency) yang menggerakkan
/// `LinearGradient` diagonal melintasi seluruh child secara efisien menggunakan satu `AnimationController`.
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE2E8F0),
    this.highlightColor = const Color(0xFFF8FAFC),
    this.duration = const Duration(milliseconds: 1400),
    this.enabled = true,
  });

  /// Widget hierarki yang akan diselimuti efek shimmer.
  final Widget child;

  /// Warna dasar skeleton saat tidak tersorot kilauan.
  final Color baseColor;

  /// Warna kilauan highlight saat sapuan gradien melintas.
  final Color highlightColor;

  /// Durasi satu siklus animasi sapuan gradien.
  final Duration duration;

  /// Mengontrol apakah animasi aktif berulang atau diam (statis).
  final bool enabled;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateAnimationState();
  }

  @override
  void didUpdateWidget(covariant SkeletonShimmer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled ||
        oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      _updateAnimationState();
    }
  }

  void _updateAnimationState() {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations || !widget.enabled) {
      if (_controller.isAnimating) {
        _controller.stop();
      }
    } else {
      if (!_controller.isAnimating) {
        _controller.repeat();
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
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations || !widget.enabled) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double value = _controller.value;
            // Sapuan gradien diagonal dari kiri (-1.5) ke kanan (1.5)
            final double startX = -1.5 + (value * 3.0);
            final double endX = startX + 1.2;

            return LinearGradient(
              begin: Alignment(startX, -0.2),
              end: Alignment(endX, 0.2),
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(bounds);
          },
          child: child,
        );
      },
    );
  }
}

/// Kotak placeholder skeleton sederhana dengan warna dasar netral, sudut membulat,
/// dan dimensi yang dapat disesuaikan.
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
    this.color,
  });

  /// Lebar kotak placeholder (`null` = menyesuaikan parent atau `double.infinity`).
  final double? width;

  /// Tinggi pasti kotak placeholder.
  final double height;

  /// Kelengkungan sudut kotak placeholder (default: 8dp).
  final BorderRadius? borderRadius;

  /// Warna dasar kotak (default: `AppColors.outline` / netral abu-abu terang).
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.outline;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: borderRadius ?? BorderRadius.circular(8),
      ),
    );
  }
}
