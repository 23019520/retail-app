import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/cart_model.dart';
import '../../../core/utils/formatters.dart';
import '../providers/cart_provider.dart';

class CartItemTile extends ConsumerWidget {
  const CartItemTile({super.key, required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // ── Product image ───────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: item.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: colors.surfaceContainerHighest,
                      ),
                      errorWidget: (_, __, ___) => _Placeholder(colors),
                    )
                  : _Placeholder(colors),
            ),
          ),

          const SizedBox(width: 14),

          // ── Name + price ────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: text.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.currency(item.price),
                  style: text.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 10),
                // ── Qty controls + subtotal ────────────────────────
                Row(
                  children: [
                    _QtyControl(item: item),
                    const Spacer(),
                    Text(
                      Formatters.currency(item.subtotal),
                      style: text.titleSmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ── Remove button ───────────────────────────────────────────
          IconButton(
            icon: Icon(
              Icons.delete_outline_rounded,
              color: colors.error.withValues(alpha: 0.7),
              size: 20,
            ),
            onPressed: () async {
              await ref
                  .read(cartNotifierProvider.notifier)
                  .removeItem(item.productId);
            },
          ),
        ],
      ),
    );
  }
}

class _QtyControl extends ConsumerWidget {
  const _QtyControl({required this.item});
  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border.all(color: colors.outline.withValues(alpha: 0.25)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Btn(
            icon: Icons.remove_rounded,
            onTap: () => ref
                .read(cartNotifierProvider.notifier)
                .updateQuantity(item.productId, item.quantity - 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              '${item.quantity}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _Btn(
            icon: Icons.add_rounded,
            enabled: !item.atMaxQuantity,
            onTap: () => ref
                .read(cartNotifierProvider.notifier)
                .updateQuantity(item.productId, item.quantity + 1),
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  const _Btn({required this.icon, required this.onTap, this.enabled = true});
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Icon(
          icon,
          size: 16,
          color: enabled
              ? colors.primary
              : colors.onSurface.withValues(alpha: 0.25),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.colors);
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.surfaceContainerHighest,
      child: Icon(Icons.image_outlined,
          color: colors.onSurfaceVariant.withValues(alpha: 0.4)),
    );
  }
}
