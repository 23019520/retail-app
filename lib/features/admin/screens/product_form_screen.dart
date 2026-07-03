import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/models/category_model.dart';
import '../../../core/models/product_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_shimmer.dart';
import '../../../core/widgets/app_states.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../theme/app_theme.dart';
import '../providers/admin_products_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _nameCtrl  = TextEditingController();
  final _descCtrl  = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();

  // ── Resale trust field controllers ──────────────────────────────────────
  final _returnDaysCtrl    = TextEditingController();
  final _warrantyCtrl      = TextEditingController();
  final _deliveredFromCtrl = TextEditingController();

  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    Future(() {
      final product = ref.read(productToEditProvider);
      if (product != null) {
        ref.read(productFormProvider.notifier).loadProduct(product);
        _nameCtrl.text  = product.name;
        _descCtrl.text  = product.description;
        _priceCtrl.text = product.price.toString();
        _stockCtrl.text = product.stock.toString();
        _returnDaysCtrl.text    = product.returnPolicyDays.toString();
        _warrantyCtrl.text      = product.warrantyMonths.toString();
        _deliveredFromCtrl.text = product.deliveredFrom;
      } else {
        // Sensible defaults for a new listing
        _returnDaysCtrl.text = '7';
        _warrantyCtrl.text   = '0';
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    _returnDaysCtrl.dispose();
    _warrantyCtrl.dispose();
    _deliveredFromCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      ref.read(productFormProvider.notifier).addImageFile(File(picked.path));
    }
  }

  /// Called whenever the category changes — clears condition/battery state
  /// if the new category's product type no longer supports them, so we
  /// never silently save stale data for the wrong product type.
  void _onCategoryChanged(String categoryId, List<CategoryModel> categories) {
    ref.read(productFormProvider.notifier).setCategoryId(categoryId);

    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel.all,
    );

    final notifier = ref.read(productFormProvider.notifier);
    if (!category.productType.hasCondition) {
      notifier.clearCondition();
    }
    if (!category.productType.hasBattery) {
      notifier.clearBatteryHealth();
    }
  }

  @override
  Widget build(BuildContext context) {
    final formState        = ref.watch(productFormProvider);
    final categoriesAsync  = ref.watch(adminCategoriesProvider);
    final editingProduct   = ref.watch(productToEditProvider);
    final isEditing        = editingProduct != null;

    ref.listen(productFormProvider, (prev, next) {
      if (next.hasError && next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: AppColors.error,
        ));
      }
    });

    if (formState.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundBase,
        body: AppLoading(message: 'Saving product...'),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundBase,
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'New Product'),
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
                  title: 'Delete product?',
                  message: '"${editingProduct.name}" will be permanently removed.',
                  confirmLabel: 'Delete',
                  isDestructive: true,
                );
                if (confirmed == true && context.mounted) {
                  await ref
                      .read(productFormProvider.notifier)
                      .delete(editingProduct);
                  if (context.mounted) context.pop();
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Images ─────────────────────────────────────────────────
              const _SectionTitle('Product Images'),
              const SizedBox(height: AppSpacing.md),
              _ImageGrid(
                existingUrls: formState.existingImageUrls,
                newFiles: formState.newImageFiles,
                onAdd: _pickImage,
                onRemoveExisting:
                    ref.read(productFormProvider.notifier).removeExistingImage,
                onRemoveNew:
                    ref.read(productFormProvider.notifier).removeNewImage,
              ),
              const SizedBox(height: AppSpacing.lg),

              // ── Details ────────────────────────────────────────────────
              const _SectionTitle('Product Details'),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Product Name',
                controller: _nameCtrl,
                validator: (v) => Validators.required(v, fieldName: 'Name'),
                textInputAction: TextInputAction.next,
                onChanged: ref.read(productFormProvider.notifier).setName,
              ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Description',
                controller: _descCtrl,
                maxLines: 4,
                textInputAction: TextInputAction.next,
                onChanged:
                    ref.read(productFormProvider.notifier).setDescription,
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Price (R)',
                      controller: _priceCtrl,
                      validator: Validators.price,
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.payments_outlined,
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        if (parsed != null) {
                          ref
                              .read(productFormProvider.notifier)
                              .setPrice(parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Stock',
                      controller: _stockCtrl,
                      validator: Validators.stock,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.inventory_2_outlined,
                      onChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null) {
                          ref
                              .read(productFormProvider.notifier)
                              .setStock(parsed);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // ── Category (drives which trust fields show below) ─────────
              categoriesAsync.when(
                loading: () => const SizedBox(height: 56),
                error: (_, __) => const SizedBox.shrink(),
                data: (categories) => DropdownButtonFormField<String>(
                  initialValue: formState.categoryId.isNotEmpty
                      ? formState.categoryId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined, size: 18),
                  ),
                  dropdownColor: AppColors.backgroundSheet,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) _onCategoryChanged(v, categories);
                  },
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Condition & Trust — only for relevant product types ─────
              categoriesAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (categories) {
                  final selectedCategory = categories.firstWhere(
                    (c) => c.id == formState.categoryId,
                    orElse: () => CategoryModel.all,
                  );
                  final type = selectedCategory.productType;

                  if (!type.hasCondition && !type.hasBattery) {
                    // Tools / non-condition items: skip this whole section.
                    return const SizedBox.shrink();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle('Condition & Trust'),
                      const SizedBox(height: AppSpacing.md),

                      if (type.hasCondition) ...[
                        const _FieldLabel('Condition Grade'),
                        const SizedBox(height: AppSpacing.sm),
                        _ConditionSelector(
                          selected: formState.condition,
                          onChanged:
                              ref.read(productFormProvider.notifier).setCondition,
                        ),
                        const SizedBox(height: AppSpacing.base),
                      ],

                      if (type.hasBattery) ...[
                        _BatteryHealthSlider(
                          value: formState.batteryHealth ?? 1.0,
                          onChanged: ref
                              .read(productFormProvider.notifier)
                              .setBatteryHealth,
                        ),
                        const SizedBox(height: AppSpacing.base),
                      ],

                      // Quality-checked / inspected toggle — applies to any
                      // category that tracks condition or battery.
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
                            'Quality Checked',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: const Text(
                            'Verified inspection — shows the trust badge to buyers',
                            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                          value: formState.isInspected,
                          onChanged: ref
                              .read(productFormProvider.notifier)
                              .setIsInspected,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                },
              ),

              // ── Returns & Warranty (applies to every product type) ──────
              const _SectionTitle('Returns & Warranty'),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Return Window (days)',
                      controller: _returnDaysCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.replay_rounded,
                      onChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null) {
                          ref
                              .read(productFormProvider.notifier)
                              .setReturnPolicyDays(parsed);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: AppTextField(
                      label: 'Warranty (months)',
                      controller: _warrantyCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      prefixIcon: Icons.shield_outlined,
                      onChanged: (v) {
                        final parsed = int.tryParse(v);
                        if (parsed != null) {
                          ref
                              .read(productFormProvider.notifier)
                              .setWarrantyMonths(parsed);
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                '0 = no returns / no warranty offered',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Delivery (applies to every product type) ────────────────
              const _SectionTitle('Delivery'),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Delivered From',
                hint: 'e.g. Johannesburg, Gauteng',
                controller: _deliveredFromCtrl,
                textInputAction: TextInputAction.done,
                prefixIcon: Icons.local_shipping_outlined,
                onChanged:
                    ref.read(productFormProvider.notifier).setDeliveredFrom,
              ),

              const SizedBox(height: AppSpacing.lg),

              // ── Active toggle ──────────────────────────────────────────
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
                    'Visible to customers',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  value: formState.isActive,
                  onChanged:
                      ref.read(productFormProvider.notifier).setIsActive,
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // ── Save ───────────────────────────────────────────────────
              AppButton(
                label: isEditing ? 'Save Changes' : 'Create Product',
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final success = await ref
                      .read(productFormProvider.notifier)
                      .save(existingProductId: editingProduct?.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                          isEditing ? 'Product updated' : 'Product created'),
                    ));
                    context.pop();
                  }
                },
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Condition selector ────────────────────────────────────────────────────────

class _ConditionSelector extends StatelessWidget {
  const _ConditionSelector({
    required this.selected,
    required this.onChanged,
  });

  final ProductCondition? selected;
  final ValueChanged<ProductCondition> onChanged;

  Color _colorFor(ProductCondition c) {
    switch (c) {
      case ProductCondition.likeNew:   return AppColors.gradeNew;
      case ProductCondition.excellent: return AppColors.gradeExcellent;
      case ProductCondition.good:      return AppColors.gradeGood;
      case ProductCondition.fair:      return AppColors.gradeFair;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: ProductCondition.values.map((c) {
        final isSelected = selected == c;
        final color = _colorFor(c);
        return GestureDetector(
          onTap: () => onChanged(c),
          child: AnimatedContainer(
            duration: AppMotion.micro,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? color.withValues(alpha: 0.12)
                  : AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppRadius.chip),
              border: Border.all(
                color: isSelected ? color.withValues(alpha: 0.5) : AppColors.divider,
                width: isSelected ? 1.5 : 0.5,
              ),
            ),
            child: Text(
              c.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.textMuted,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Battery health slider ─────────────────────────────────────────────────────

class _BatteryHealthSlider extends StatelessWidget {
  const _BatteryHealthSlider({
    required this.value,
    required this.onChanged,
  });

  final double value;
  final ValueChanged<double> onChanged;

  Color get _color {
    if (value >= 0.85) return AppColors.gradeNew;
    if (value >= 0.70) return AppColors.gradeGood;
    if (value >= 0.50) return AppColors.secondary;
    return AppColors.gradeFair;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.bolt_rounded, size: 16, color: AppColors.secondary),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'Battery Health',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${(value * 100).round()}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: _color,
                ),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _color,
              inactiveTrackColor: AppColors.divider,
              thumbColor: _color,
              overlayColor: _color.withValues(alpha: 0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: value.clamp(0.0, 1.0),
              min: 0,
              max: 1,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Image grid ────────────────────────────────────────────────────────────────

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({
    required this.existingUrls,
    required this.newFiles,
    required this.onAdd,
    required this.onRemoveExisting,
    required this.onRemoveNew,
  });

  final List<String> existingUrls;
  final List<File>   newFiles;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemoveExisting;
  final ValueChanged<File>   onRemoveNew;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        ...existingUrls.map((url) => _ImageThumb(
              onRemove: () => onRemoveExisting(url),
              child: Image.network(url, fit: BoxFit.cover),
            )),
        ...newFiles.map((file) => _ImageThumb(
              onRemove: () => onRemoveNew(file),
              child: Image.file(file, fit: BoxFit.cover),
            )),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(
                color: AppColors.divider,
                width: 0.5,
              ),
            ),
            child: const Icon(
              Icons.add_photo_alternate_outlined,
              color: AppColors.textMuted,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({required this.child, required this.onRemove});

  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: SizedBox(width: 80, height: 80, child: child),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Labels ─────────────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      ),
    );
  }
}