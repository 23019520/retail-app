import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/category_model.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../theme/app_theme.dart';
import '../providers/admin_categories_provider.dart';

class CategoryFormScreen extends ConsumerStatefulWidget {
  const CategoryFormScreen({super.key});

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  final _nameCtrl      = TextEditingController();
  final _sortCtrl      = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future(() {
      final cat = ref.read(categoryToEditProvider);
      if (cat != null) {
        ref.read(categoryFormProvider.notifier).loadCategory(cat);
        _nameCtrl.text = cat.name;
        _sortCtrl.text = cat.sortOrder.toString();
      } else {
        _sortCtrl.text = '0';
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _sortCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formState     = ref.watch(categoryFormProvider);
    final editingCat    = ref.watch(categoryToEditProvider);
    final isEditing     = editingCat != null;

    ref.listen(categoryFormProvider, (prev, next) {
      if (next.hasError && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: AppColors.error,
        ));
      }
    });

    if (formState.isLoading) {
      return const Scaffold(
        body: AppLoading(message: 'Saving category...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Category' : 'New Category'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, size: 20),
          color: AppColors.textSecondary,
          onPressed: context.pop,
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () async {
                final confirmed = await showConfirmationDialog(
                  context,
                  title: 'Delete category?',
                  message:
                      '"${editingCat.name}" will be deleted. Products in this '
                      'category will need to be reassigned.',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                );
                if (confirmed && context.mounted) {
                  final ok = await ref
                      .read(categoryFormProvider.notifier)
                      .delete(editingCat.id);
                  if (ok && context.mounted) context.pop();
                }
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: AppColors.error),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.base),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── Name ────────────────────────────────────────────────────
            const _SectionTitle('Category Name'),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Name',
              hint: 'e.g. Laptops, Accessories, Tools',
              controller: _nameCtrl,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
              textInputAction: TextInputAction.next,
              prefixIcon: Icons.label_outline_rounded,
              onChanged: ref.read(categoryFormProvider.notifier).setName,
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Product type ────────────────────────────────────────────
            const _SectionTitle('Product Type'),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Determines which trust fields (condition grade, battery health) '
              'the product form shows for items in this category.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.5),
            ),
            const SizedBox(height: AppSpacing.md),
            _ProductTypeSelector(
              selected: formState.productType,
              onChanged:
                  ref.read(categoryFormProvider.notifier).setProductType,
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Icon ────────────────────────────────────────────────────
            const _SectionTitle('Icon'),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Shown on the category chip row.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            _IconPicker(
              selected: formState.iconName,
              onChanged:
                  ref.read(categoryFormProvider.notifier).setIconName,
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Sort order ──────────────────────────────────────────────
            const _SectionTitle('Sort Order'),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Lower numbers appear first in the category chip row.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: 'Sort Order',
              controller: _sortCtrl,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              prefixIcon: Icons.sort_rounded,
              onChanged: (v) {
                final parsed = int.tryParse(v);
                if (parsed != null) {
                  ref
                      .read(categoryFormProvider.notifier)
                      .setSortOrder(parsed);
                }
              },
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Active toggle ───────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.divider, width: 0.5),
              ),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.base,
                  vertical: AppSpacing.xs,
                ),
                title: const Text(
                  'Active',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: const Text(
                  'Visible to customers in the category filter',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
                value: formState.isActive,
                onChanged:
                    ref.read(categoryFormProvider.notifier).setIsActive,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Save ────────────────────────────────────────────────────
            AppButton(
              label: isEditing ? 'Save Changes' : 'Create Category',
              onPressed: () async {
                if (_nameCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category name is required.'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                final ok = await ref
                    .read(categoryFormProvider.notifier)
                    .save(existingId: editingCat?.id);
                if (ok && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        isEditing ? 'Category updated' : 'Category created'),
                  ));
                  context.pop();
                }
              },
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ── Product type selector ─────────────────────────────────────────────────────

class _ProductTypeSelector extends StatelessWidget {
  const _ProductTypeSelector({
    required this.selected,
    required this.onChanged,
  });

  final ProductType selected;
  final ValueChanged<ProductType> onChanged;

  static const _descriptions = {
    ProductType.electronics:
        'Full trust fields:\ncondition grade + battery health',
    ProductType.accessory:
        'Partial trust fields:\ncondition grade only',
    ProductType.tool:
        'No trust fields:\nstandard listing only',
  };

  static const _icons = {
    ProductType.electronics: Icons.laptop_mac_outlined,
    ProductType.accessory:   Icons.keyboard_outlined,
    ProductType.tool:        Icons.build_outlined,
  };

  Color _colorFor(ProductType t) {
    switch (t) {
      case ProductType.electronics: return AppColors.primary;
      case ProductType.accessory:   return AppColors.secondary;
      case ProductType.tool:        return AppColors.gradeGood;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ProductType.values.map((type) {
        final isSelected = selected == type;
        final color = _colorFor(type);
        return GestureDetector(
          onTap: () => onChanged(type),
          child: AnimatedContainer(
            duration: AppMotion.micro,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: AppSpacing.sm),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.08)
                  : AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: isSelected ? color.withValues(alpha: 0.4) : AppColors.divider,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: Icon(
                    _icons[type]!,
                    size: 18,
                    color: color,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        type.label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? color : AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        _descriptions[type]!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                AnimatedContainer(
                  duration: AppMotion.micro,
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? color : AppColors.divider,
                      width: 1.5,
                    ),
                    color: isSelected ? color : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Icon picker ───────────────────────────────────────────────────────────────

class _IconPicker extends StatelessWidget {
  const _IconPicker({required this.selected, required this.onChanged});

  final String selected;
  final ValueChanged<String> onChanged;

  static const _icons = <String, IconData>{
    'laptop':          Icons.laptop_mac_outlined,
    'desktop_windows': Icons.desktop_windows_outlined,
    'keyboard':        Icons.keyboard_outlined,
    'mouse':           Icons.mouse_outlined,
    'headphones':      Icons.headphones_outlined,
    'tablet':          Icons.tablet_outlined,
    'monitor':         Icons.monitor_outlined,
    'phone':           Icons.phone_android_outlined,
    'cable':           Icons.cable_outlined,
    'battery':         Icons.battery_full_outlined,
    'bag':             Icons.work_outline_rounded,
    'build':           Icons.build_outlined,
    'grid_view':       Icons.grid_view_rounded,
    'apps':            Icons.apps_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: _icons.entries.map((e) {
        final isSelected = selected == e.key;
        return GestureDetector(
          onTap: () => onChanged(e.key),
          child: AnimatedContainer(
            duration: AppMotion.micro,
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.5)
                    : AppColors.divider,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Icon(
              e.value,
              size: 22,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Shared ────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
          letterSpacing: 0.3,
        ),
      );
}