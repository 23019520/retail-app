import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/route_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_button.dart';
import '../../../theme/app_theme.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ── Success animation ────────────────────────────────────────
              const _SuccessIcon(),

              const SizedBox(height: AppSpacing.xl),

              const Text(
                'Order placed',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Text(
                "We've received your order. You'll get a confirmation once it's on its way.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Order reference ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.base,
                ),
                decoration: BoxDecoration(
                  color: AppColors.backgroundCard,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.divider, width: 0.5),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Order reference',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      Formatters.orderId(orderId),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // ── Actions ──────────────────────────────────────────────────
              AppButton(
                label: 'Track my order',
                onPressed: () => context.go(RouteConstants.orderHistory),
                icon: Icons.local_shipping_outlined,
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: 'Continue shopping',
                onPressed: () => context.go(RouteConstants.home),
                style: AppButtonStyle.outlined,
              ),

              const SizedBox(height: AppSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Success Icon ──────────────────────────────────────────────────────────────

class _SuccessIcon extends StatefulWidget {
  const _SuccessIcon();

  @override
  State<_SuccessIcon> createState() => _SuccessIconState();
}

class _SuccessIconState extends State<_SuccessIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    );
    _ring = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    );
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => SizedBox(
        width: 140,
        height: 140,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Ripple ring
            Transform.scale(
              scale: 0.5 + _ring.value * 0.5,
              child: Opacity(
                opacity: (1 - _ring.value).clamp(0, 1),
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primary.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
            // Icon circle
            Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.15),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 38,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
