/// AppProductImage — consistent product image presentation on dark cards.
/// Wraps raw images in a soft radial gradient backdrop so white-background
/// product photos don't clash with dark surfaces.
library app_product_image;

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class AppProductImage extends StatelessWidget {
  const AppProductImage({
    super.key,
    required this.imageUrls,
    this.height = 160,
    this.borderRadius,
    this.fit = BoxFit.contain,
    this.showFallback = true,
  });

  /// Pass first URL for single images, or all URLs for carousel behaviour.
  final List<String> imageUrls;
  final double height;
  final BorderRadius? borderRadius;
  final BoxFit fit;
  final bool showFallback;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ??
        const BorderRadius.vertical(top: Radius.circular(AppRadius.card));

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        children: [
          // ── Radial gradient backdrop ─────────────────────────────────────
          Container(
            height: height,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 0.85,
                colors: [
                  Color(0xFF252830), // slightly lighter centre
                  AppColors.backgroundCard,
                ],
              ),
            ),
          ),

          // ── Image ────────────────────────────────────────────────────────
          if (imageUrls.isNotEmpty)
            SizedBox(
              height: height,
              width: double.infinity,
              child: Image.network(
                imageUrls.first,
                fit: fit,
                height: height,
                loadingBuilder: (ctx, child, progress) {
                  if (progress == null) return child;
                  return const _ImagePlaceholder();
                },
                errorBuilder: (_, __, ___) =>
                    showFallback ? const _ImageFallback() : const SizedBox(),
              ),
            )
          else
            SizedBox(height: height, child: const _ImageFallback()),

          // ── Subtle bottom vignette ────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: height * 0.35,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.backgroundCard.withValues(alpha: 0.9),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundSheet,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.divider),
          ),
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  const _ImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundSheet,
      child: const Center(
        child: Icon(
          Icons.laptop_mac_rounded,
          size: 48,
          color: AppColors.divider,
          semanticLabel: 'No image available',
        ),
      ),
    );
  }
}

/// Multi-image carousel with dot indicators.
class AppProductImageCarousel extends StatefulWidget {
  const AppProductImageCarousel({
    super.key,
    required this.imageUrls,
    this.height = 280,
  });

  final List<String> imageUrls;
  final double height;

  @override
  State<AppProductImageCarousel> createState() =>
      _AppProductImageCarouselState();
}

class _AppProductImageCarouselState extends State<AppProductImageCarousel> {
  final _pageController = PageController();
  int _current = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return AppProductImage(
        imageUrls: const [],
        height: widget.height,
        borderRadius: BorderRadius.zero,
      );
    }

    return Stack(
      children: [
        // ── Page view ─────────────────────────────────────────────────────
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.imageUrls.length,
            onPageChanged: (i) => setState(() => _current = i),
            itemBuilder: (_, i) => AppProductImage(
              imageUrls: [widget.imageUrls[i]],
              height: widget.height,
              borderRadius: BorderRadius.zero,
              fit: BoxFit.contain,
            ),
          ),
        ),

        // ── Dot indicators ────────────────────────────────────────────────
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 14,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (i) {
                final active = i == _current;
                return AnimatedContainer(
                  duration: AppMotion.micro,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}
