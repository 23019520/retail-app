import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../core/models/product_model.dart';
import '../../../core/utils/formatters.dart';

class AdminProductTile extends StatelessWidget {
  const AdminProductTile({
    super.key,
    required this.product,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 64,
              height: 64,
              child: product.primaryImage != null
                  ? CachedNetworkImage(
                      imageUrl: product.primaryImage!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          color: colors.surfaceContainerHighest),
                      errorWidget: (_, __, ___) =>
                          _Placeholder(colors: colors),
                    )
                  : _Placeholder(colors: colors),
            ),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: text.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Active/Inactive badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (product.isActive
                                ? Colors.green
                                : colors.error)
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        product.isActive ? 'Active' : 'Inactive',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: product.isActive
                              ? Colors.green
                              : colors.error,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Text(
                      Formatters.currency(product.price),
                      style: text.bodySmall?.copyWith(
                        color: colors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 13,
                      color: product.lowStock
                          ? Colors.orange
                          : colors.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${product.stock} in stock',
                      style: text.bodySmall?.copyWith(
                        color: product.lowStock
                            ? Colors.orange
                            : colors.onSurface.withValues(alpha: 0.5),
                        fontWeight: product.lowStock
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          Column(
            children: [
              _ActionButton(
                icon: Icons.edit_outlined,
                color: colors.primary,
                onTap: onEdit,
              ),
              const SizedBox(height: 6),
              _ActionButton(
                icon: Icons.delete_outline_rounded,
                color: colors.error,
                onTap: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 17),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.colors});
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colors.surfaceContainerHighest,
      child: Icon(
        Icons.image_outlined,
        color: colors.onSurfaceVariant.withValues(alpha: 0.4),
        size: 24,
      ),
    );
  }
}
