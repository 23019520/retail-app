import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/utils/formatters.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Success animation ───────────────────────────────
              _SuccessIcon(colors: colors),

              const SizedBox(height: 32),

              Text(
                'Order Placed!',
                style: text.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "We've received your order and it's being processed. You'll be notified when it's on its way.",
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 32),

              // ── Order ID badge ──────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: colors.outline.withValues(alpha: 0.2)),
                ),
                child: Column(
                  children: [
                    Text(
                      'Order Reference',
                      style: text.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      Formatters.orderId(orderId),
                      style: text.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Actions ─────────────────────────────────────────
              FilledButton(
                onPressed: () => context.go(RouteConstants.orderHistory),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Track my order'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go(RouteConstants.home),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Continue Shopping'),
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated success checkmark with ripple rings.
class _SuccessIcon extends StatefulWidget {
  const _SuccessIcon({required this.colors});
  final ColorScheme colors;

  @override
  State<_SuccessIcon> createState() => _SuccessIconState();
}

class _SuccessIconState extends State<_SuccessIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _ringAnim = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
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
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: 160,
          height: 160,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer ring
              Transform.scale(
                scale: 0.5 + (_ringAnim.value * 0.5),
                child: Opacity(
                  opacity: (1 - _ringAnim.value).clamp(0.0, 1.0),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ),
              // Middle ring
              Transform.scale(
                scale: 0.6 + (_ringAnim.value * 0.4),
                child: Opacity(
                  opacity: (0.8 - _ringAnim.value * 0.8).clamp(0.0, 1.0),
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green.withValues(alpha: 0.2),
                    ),
                  ),
                ),
              ),
              // Icon circle
              Transform.scale(
                scale: _scaleAnim.value,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
