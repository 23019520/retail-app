import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    // Listen for auth state and navigate when ready
    ref.listen(authStateProvider, (previous, next) {
      if (next.isLoading) return;
      if (next.hasValue) {
        final user = next.value;
        if (context.mounted) {
          context.go(
            user != null ? RouteConstants.home : RouteConstants.login,
          );
        }
      }
    });

    final isLoading = ref.watch(authStateProvider).isLoading;

    return Scaffold(
      backgroundColor: colors.primary,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Transform.scale(
                  scale: _scaleAnim.value,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: colors.onPrimary,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        size: 52,
                        color: colors.primary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // App name
                FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    'My Store',
                    style: text.headlineMedium?.copyWith(
                      color: colors.onPrimary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    'Shop smarter',
                    style: text.bodyMedium?.copyWith(
                      color: colors.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
                ),

                const SizedBox(height: 64),

                // Loading indicator
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: colors.onPrimary.withValues(alpha: 0.7),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
