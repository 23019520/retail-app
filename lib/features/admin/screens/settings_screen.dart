import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../core/models/business_model.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_loading.dart';
import '../../../core/widgets/app_text_field.dart';
import '../providers/admin_settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  File? _newLogoFile;
  bool _initialised = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _initFromBusiness(BusinessModel business) {
    if (_initialised) return;
    _initialised = true;
    _nameCtrl.text = business.name;
    _phoneCtrl.text = business.phone ?? '';
    _emailCtrl.text = business.email ?? '';
    _addressCtrl.text = business.address ?? '';
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() => _newLogoFile = File(picked.path));
    }
  }

  Future<void> _save(BusinessModel current) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSaving = true);

    final updated = current.copyWith(
      name: _nameCtrl.text.trim(),
      phone: _phoneCtrl.text.trim().isNotEmpty
          ? _phoneCtrl.text.trim()
          : null,
      email: _emailCtrl.text.trim().isNotEmpty
          ? _emailCtrl.text.trim()
          : null,
      address: _addressCtrl.text.trim().isNotEmpty
          ? _addressCtrl.text.trim()
          : null,
    );

    final success = await ref
        .read(adminSettingsProvider.notifier)
        .save(updated, newLogoFile: _newLogoFile);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(success ? 'Settings saved' : 'Failed to save settings'),
          backgroundColor: success
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      if (success) setState(() => _newLogoFile = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(adminSettingsProvider);
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return settingsAsync.when(
      loading: () => const Scaffold(body: AppLoading()),
      error: (_, __) => const Scaffold(
          body: Center(child: Text('Could not load settings.'))),
      data: (business) {
        _initFromBusiness(business);

        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Settings',
                        style: text.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 24),

                    // ── Logo ───────────────────────────────────────
                    const _SectionTitle('Business Logo'),
                    const SizedBox(height: 12),
                    _LogoPicker(
                      existingUrl: business.logoUrl,
                      newFile: _newLogoFile,
                      onPick: _pickLogo,
                      onRemove: () => setState(() => _newLogoFile = null),
                      colors: colors,
                    ),
                    const SizedBox(height: 24),

                    // ── Business info ──────────────────────────────
                    const _SectionTitle('Business Information'),
                    const SizedBox(height: 12),
                    AppTextField(
                      label: 'Business Name',
                      controller: _nameCtrl,
                      validator: (v) =>
                          Validators.required(v, fieldName: 'Name'),
                      prefixIcon: Icons.store_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Phone Number',
                      controller: _phoneCtrl,
                      validator: Validators.phone,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Email Address',
                      controller: _emailCtrl,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        return Validators.email(v);
                      },
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Address',
                      controller: _addressCtrl,
                      maxLines: 2,
                      prefixIcon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.done,
                    ),

                    const SizedBox(height: 28),

                    // ── Branding colours preview ───────────────────
                    const _SectionTitle('Brand Colors'),
                    const SizedBox(height: 12),
                    _ColorPreview(
                      primaryColor: colors.primary,
                      secondaryColor: colors.secondary,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Colors are set from your business config in Firestore. '
                        'Full color picker coming in a future update.',
                        style: text.bodySmall?.copyWith(
                          color:
                              colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Save ──────────────────────────────────────
                    AppButton(
                      label: 'Save Settings',
                      isLoading: _isSaving,
                      onPressed: () => _save(business),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
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

class _LogoPicker extends StatelessWidget {
  const _LogoPicker({
    required this.existingUrl,
    required this.newFile,
    required this.onPick,
    required this.onRemove,
    required this.colors,
  });

  final String? existingUrl;
  final File? newFile;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final hasImage = newFile != null || existingUrl != null;

    return Row(
      children: [
        // Preview
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: colors.outline.withValues(alpha: 0.2)),
          ),
          clipBehavior: Clip.antiAlias,
          child: hasImage
              ? newFile != null
                  ? Image.file(newFile!, fit: BoxFit.cover)
                  : Image.network(existingUrl!, fit: BoxFit.cover)
              : Icon(
                  Icons.store_outlined,
                  size: 36,
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            OutlinedButton.icon(
              onPressed: onPick,
              icon: const Icon(Icons.upload_rounded, size: 18),
              label:
                  Text(hasImage ? 'Change Logo' : 'Upload Logo'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
            if (hasImage) ...[
              const SizedBox(height: 6),
              TextButton(
                onPressed: onRemove,
                style: TextButton.styleFrom(
                  foregroundColor: colors.error,
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                ),
                child: const Text('Remove', style: TextStyle(fontSize: 12)),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ColorPreview extends StatelessWidget {
  const _ColorPreview({
    required this.primaryColor,
    required this.secondaryColor,
  });
  final Color primaryColor;
  final Color secondaryColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ColorSwatch(label: 'Primary', color: primaryColor),
        const SizedBox(width: 12),
        _ColorSwatch(label: 'Secondary', color: secondaryColor),
      ],
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }
}
