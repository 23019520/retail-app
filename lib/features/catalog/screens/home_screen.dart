import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_stagger.dart';
import '../../../theme/app_theme.dart';
import '../providers/products_provider.dart';
import '../widgets/category_chip.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredProductsProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: AppStagger(
        child: CustomScrollView(
          slivers: [
            // ── App bar ──────────────────────────────────────────────────
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              
              expandedHeight: 0,
              title: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.chip),
                    ),
                    child: const Icon(
                      Icons.devices_rounded,
                      color: Color(0xFF0E2419),
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  const Text(
                    'BrightDev Store',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.notifications_none_rounded),
                  color: AppColors.textSecondary,
                  onPressed: () {},
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
            ),

            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.sm),

                  // ── Search bar ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.base),
                    child: SearchBarWidget(
                      readOnly: true,
                      onTap: () => context.go(RouteConstants.productList),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Auto-sliding banner ───────────────────────────────
                  AppStaggerItem(
                    index: 0,
                    child: const _PromoBannerSlider(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Categories ────────────────────────────────────────
                  const AppStaggerItem(
                    index: 1,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AppSpacing.base,
                        bottom: AppSpacing.md,
                      ),
                      child: Text(
                        'Categories',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const AppStaggerItem(
                    index: 2,
                    child: CategoryChipRow(),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // ── Featured header ───────────────────────────────────
                  AppStaggerItem(
                    index: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.base),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Featured',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () =>
                                context.go(RouteConstants.productList),
                            child: const Text('See all'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),

            // ── Featured products grid ─────────────────────────────────
            featuredAsync.when(
              loading: () => const SliverToBoxAdapter(
                child: ProductGridSkeleton(count: 4),
              ),
              error: (_, __) => const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppSpacing.xl),
                        child: Text(
                          'No products yet',
                          style: TextStyle(color: AppColors.textMuted),
                        ),
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.base,
                    0,
                    AppSpacing.base,
                    AppSpacing.xl,
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => AppStaggerItem(
                        index: index + 4,
                        child: ProductCard(product: products[index]),
                      ),
                      childCount: products.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Promo Banner Slider ───────────────────────────────────────────────────────

class _SlideData {
  const _SlideData({
    required this.headline,
    required this.sub,
    required this.icon,
    required this.accentColor,
    required this.gradientColors,
  });

  final String headline;
  final String sub;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;
}

const _slides = [
  _SlideData(
    headline: 'Quality laptops\nfrom R3,500',
    sub: 'Graded, battery-checked and ready to go.',
    icon: Icons.laptop_mac_rounded,
    accentColor: AppColors.primary,
    gradientColors: [Color(0xFFEDF7F2), Color(0xFFF7F8FA)],
  ),
  _SlideData(
    headline: 'Powerful desktops\nbuilt to perform',
    sub: 'Pre-owned towers and all-in-ones, inspected.',
    icon: Icons.desktop_windows_rounded,
    accentColor: Color(0xFF4A90C4),
    gradientColors: [Color(0xFFEBF4FB), Color(0xFFF7F8FA)],
  ),
  _SlideData(
    headline: 'Accessories &\nperipherals',
    sub: 'Keyboards, mice, bags, cables and more.',
    icon: Icons.keyboard_rounded,
    accentColor: AppColors.secondary,
    gradientColors: [Color(0xFFFBF5EA), Color(0xFFF7F8FA)],
  ),
];

class _PromoBannerSlider extends StatefulWidget {
  const _PromoBannerSlider();

  @override
  State<_PromoBannerSlider> createState() => _PromoBannerSliderState();
}

class _PromoBannerSliderState extends State<_PromoBannerSlider>
    with SingleTickerProviderStateMixin {
  final _controller = PageController();
  late final AnimationController _dotCtrl;
  int _current = 0;

  static const _autoAdvanceMs = 3800;

  @override
  void initState() {
    super.initState();

    _dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _autoAdvanceMs),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _advance();
        }
      });

    // Start the first auto-advance cycle after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _dotCtrl.forward();
    });
  }

  void _advance() {
    if (!mounted) return;
    final next = (_current + 1) % _slides.length;
    _controller.animateToPage(
      next,
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeInOutCubic,
    );
    // _dotCtrl resets and restarts once the page settles (via onPageChanged)
  }

  void _goTo(int index) {
    _dotCtrl.stop();
    _controller.animateToPage(
      index,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _dotCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: Column(
        children: [
          // ── Page view ───────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: SizedBox(
              height: 152,
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) {
                  setState(() => _current = i);
                  // Reset and restart the dot progress animation
                  _dotCtrl.reset();
                  _dotCtrl.forward();
                },
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return _BannerSlide(slide: slide);
                },
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Animated dot indicators ─────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_slides.length, (i) {
              final isActive = i == _current;
              final accentColor = _slides[i].accentColor;

              return GestureDetector(
                onTap: () => _goTo(i),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: isActive
                      // Active dot: shows progress fill via AnimatedBuilder
                      ? SizedBox(
                          width: 28,
                          height: 6,
                          child: AnimatedBuilder(
                            animation: _dotCtrl,
                            builder: (_, __) => ClipRRect(
                              borderRadius: BorderRadius.circular(3),
                              child: Stack(
                                children: [
                                  // Track
                                  Container(
                                    color: accentColor.withValues(alpha: 0.2),
                                  ),
                                  // Fill
                                  FractionallySizedBox(
                                    widthFactor: _dotCtrl.value,
                                    child: Container(color: accentColor),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      // Inactive dots
                      : AnimatedContainer(
                          duration: AppMotion.micro,
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.divider,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Individual slide ──────────────────────────────────────────────────────────

class _BannerSlide extends StatelessWidget {
  const _BannerSlide({required this.slide});

  final _SlideData slide;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: slide.gradientColors,
        ),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Stack(
        children: [
          // Accent glow — top left
          Positioned(
            top: -24,
            left: -24,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: slide.accentColor.withValues(alpha: 0.07),
              ),
            ),
          ),

          // Text content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Accent line
                Container(
                  width: 28,
                  height: 3,
                  decoration: BoxDecoration(
                    color: slide.accentColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  slide.headline,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  slide.sub,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Icon — right side, faded
          Positioned(
            right: AppSpacing.lg,
            top: 0,
            bottom: 0,
            child: Icon(
              slide.icon,
              size: 76,
              color: slide.accentColor.withValues(alpha: 0.08),
            ),
          ),

          // Small accent icon — bottom right, visible
          Positioned(
            right: AppSpacing.base,
            bottom: AppSpacing.base,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: slide.accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.chip),
              ),
              child: Icon(
                slide.icon,
                size: 14,
                color: slide.accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}