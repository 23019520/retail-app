import 'package:flutter/material.dart';

/// Full-width promotional banner shown at the top of HomeScreen.
/// Accepts a list of banners and auto-scrolls between them.
class PromoBanner extends StatefulWidget {
  const PromoBanner({super.key, this.banners = const []});

  final List<BannerData> banners;

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final _pageController = PageController();
  int _currentPage = 0;

  List<BannerData> get _items =>
      widget.banners.isEmpty ? BannerData.defaults : widget.banners;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemCount: _items.length,
            itemBuilder: (context, index) =>
                _BannerCard(data: _items[index]),
          ),
        ),
        if (_items.length > 1) ...[
          const SizedBox(height: 10),
          _DotIndicator(
            count: _items.length,
            current: _currentPage,
          ),
        ],
      ],
    );
  }
}

class _BannerCard extends StatelessWidget {
  const _BannerCard({required this.data});
  final BannerData data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: data.gradientColors ??
                [colors.primary, colors.tertiary],
          ),
          image: data.imageUrl != null
              ? DecorationImage(
                  image: NetworkImage(data.imageUrl!),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withValues(alpha: 0.35),
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (data.badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.badge!,
                    style: text.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 6),
              Text(
                data.title,
                style: text.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              if (data.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  data.subtitle!,
                  style: text.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});
  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 20 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? colors.primary
                : colors.primary.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

/// Data model for a single banner.
class BannerData {
  const BannerData({
    required this.title,
    this.subtitle,
    this.badge,
    this.imageUrl,
    this.gradientColors,
  });

  final String title;
  final String? subtitle;
  final String? badge;
  final String? imageUrl;
  final List<Color>? gradientColors;

  /// Default banners shown before Firestore data loads.
  static const List<BannerData> defaults = [
    BannerData(
      title: 'Welcome to\nour store',
      subtitle: 'Discover our latest products',
      badge: '✨ New arrivals',
    ),
    BannerData(
      title: 'Free delivery\nover R500',
      subtitle: 'Shop more, save more',
      badge: '🚚 Free shipping',
      gradientColors: [Color(0xFF0F3460), Color(0xFFE94560)],
    ),
  ];
}
