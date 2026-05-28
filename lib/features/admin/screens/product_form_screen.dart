import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/admin_products_provider.dart';

class ProductFormScreen extends ConsumerStatefulWidget {
  const ProductFormScreen({super.key});

  @override
  ConsumerState<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends ConsumerState<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _picker = ImagePicker();
  bool _initialised = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _stockCtrl.dispose();
    super.dispose();
  }

  void _initFromProduct() {
    if (_initialised) return;
    _initialised = true;
    final product = ref.read(productToEditProvider);
    if (product != null) {
      ref.read(productFormProvider.notifier).loadProduct(product);
      _nameCtrl.text = product.name;
      _descCtrl.text = product.description;
      _priceCtrl.text = product.price.toString();
      _stockCtrl.text = product.stock.toString();
    }
  }

  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      ref
          .read(productFormProvider.notifier)
          .addImageFile(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    _initFromProduct();

    final formState = ref.watch(productFormProvider);
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final editingProduct = ref.watch(productToEditProvider);
    final isEditing = editingProduct != null;
    final colors = Theme.of(context).colorScheme;

    ref.listen(productFormProvider, (previous, next) {
      if (next.hasError && next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(next.errorMessage!),
          backgroundColor: colors.error,
          behavior: SnackBarBehavior.floating,
        ));
      }
    });

    if (formState.isLoading) {
      return const Scaffold(body: AppLoading(message: 'Saving product...'));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Product' : 'New Product'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (isEditing)
            TextButton(
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Delete product?'),
                    content: Text(
                        '"${editingProduct.name}" will be permanently removed.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel'),
                      ),
                      FilledButton(
                        style: FilledButton.styleFrom(
                            backgroundColor: colors.error),
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );
                if (confirmed == true && context.mounted) {
                  await ref
                      .read(productFormProvider.notifier)
                      .delete(editingProduct);
                  if (context.mounted) context.pop();
                }
              },
              child: Text('Delete',
                  style: TextStyle(color: colors.error)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Images ────────────────────────────────────────────
              _SectionTitle('Product Images'),
              const SizedBox(height: 12),
              _ImageGrid(
                existingUrls: formState.existingImageUrls,
                newFiles: formState.newImageFiles,
                onAdd: _pickImage,
                onRemoveExisting: ref
                    .read(productFormProvider.notifier)
                    .removeExistingImage,
                onRemoveNew:
                    ref.read(productFormProvider.notifier).removeNewImage,
                colors: colors,
              ),
              const SizedBox(height: 24),

              // ── Details ───────────────────────────────────────────
              _SectionTitle('Product Details'),
              const SizedBox(height: 12),
              AppTextField(
                label: 'Product Name',
                controller: _nameCtrl,
                validator: (v) =>
                    Validators.required(v, fieldName: 'Name'),
                textInputAction: TextInputAction.next,
                onChanged:
                    ref.read(productFormProvider.notifier).setName,
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Description',
                controller: _descCtrl,
                maxLines: 4,
                textInputAction: TextInputAction.next,
                onChanged: ref
                    .read(productFormProvider.notifier)
                    .setDescription,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'Price (R)',
                      controller: _priceCtrl,
                      validator: Validators.price,
                      keyboardType:
                          const TextInputType.numberWithOptions(
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
                  const SizedBox(width: 14),
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
              const SizedBox(height: 14),

              // ── Category ──────────────────────────────────────────
              categoriesAsync.when(
                loading: () => const SizedBox(height: 56),
                error: (_, __) => const SizedBox.shrink(),
                data: (categories) =>
                    DropdownButtonFormField<String>(
                  value: formState.categoryId.isNotEmpty
                      ? formState.categoryId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categories
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) {
                      ref
                          .read(productFormProvider.notifier)
                          .setCategoryId(v);
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                ),
              ),

              const SizedBox(height: 16),

              // ── Active toggle ─────────────────────────────────────
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Active'),
                subtitle: const Text('Visible to customers'),
                value: formState.isActive,
                onChanged:
                    ref.read(productFormProvider.notifier).setIsActive,
              ),

              const SizedBox(height: 28),

              // ── Save ──────────────────────────────────────────────
              AppButton(
                label: isEditing ? 'Save Changes' : 'Create Product',
                onPressed: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }
                  final success = await ref
                      .read(productFormProvider.notifier)
                      .save(existingProductId: editingProduct?.id);
                  if (success && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing
                            ? 'Product updated'
                            : 'Product created'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    context.pop();
                  }
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context)
          .textTheme
          .titleSmall
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid({
    required this.existingUrls,
    required this.newFiles,
    required this.onAdd,
    required this.onRemoveExisting,
    required this.onRemoveNew,
    required this.colors,
  });

  final List<String> existingUrls;
  final List<File> newFiles;
  final VoidCallback onAdd;
  final ValueChanged<String> onRemoveExisting;
  final ValueChanged<File> onRemoveNew;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ...existingUrls.map((url) => _ImageThumb(
              child: Image.network(url, fit: BoxFit.cover),
              onRemove: () => onRemoveExisting(url),
              colors: colors,
            )),
        ...newFiles.map((file) => _ImageThumb(
              child: Image.file(file, fit: BoxFit.cover),
              onRemove: () => onRemoveNew(file),
              colors: colors,
            )),
        GestureDetector(
          onTap: onAdd,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colors.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.add_photo_alternate_outlined,
              color: colors.onSurfaceVariant,
              size: 28,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImageThumb extends StatelessWidget {
  const _ImageThumb({
    required this.child,
    required this.onRemove,
    required this.colors,
  });
  final Widget child;
  final VoidCallback onRemove;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(width: 80, height: 80, child: child),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: colors.error,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
