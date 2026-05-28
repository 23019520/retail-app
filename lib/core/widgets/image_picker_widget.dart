import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Standalone image picker widget with preview.
/// Shows a placeholder tap target until an image is selected,
/// then shows the image with a remove button overlay.
class ImagePickerWidget extends StatefulWidget {
  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    required this.onImageSelected,
    this.onImageRemoved,
    this.width = 120,
    this.height = 120,
    this.borderRadius = 12,
    this.placeholderIcon = Icons.add_photo_alternate_outlined,
  });

  final String? initialImageUrl;
  final ValueChanged<File> onImageSelected;
  final VoidCallback? onImageRemoved;
  final double width;
  final double height;
  final double borderRadius;
  final IconData placeholderIcon;

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  final _picker = ImagePicker();
  File? _selectedFile;

  Future<void> _pick() async {
    final result = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (result != null) {
      final file = File(result.path);
      setState(() => _selectedFile = file);
      widget.onImageSelected(file);
    }
  }

  void _remove() {
    setState(() => _selectedFile = null);
    widget.onImageRemoved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final hasFile = _selectedFile != null;
    final hasUrl = widget.initialImageUrl != null;
    final hasImage = hasFile || hasUrl;

    return GestureDetector(
      onTap: _pick,
      child: Stack(
        children: [
          Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              border: Border.all(
                color: hasImage
                    ? colors.primary.withValues(alpha: 0.3)
                    : colors.outline.withValues(alpha: 0.3),
                width: hasImage ? 2 : 1,
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: hasFile
                ? Image.file(_selectedFile!, fit: BoxFit.cover)
                : hasUrl
                    ? Image.network(
                        widget.initialImageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _Placeholder(colors, widget.placeholderIcon),
                      )
                    : _Placeholder(colors, widget.placeholderIcon),
          ),

          // Remove button
          if (hasImage)
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: _remove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colors.error,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            ),

          // Edit overlay hint
          if (hasImage)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.only(
                    bottomLeft:
                        Radius.circular(widget.borderRadius),
                    bottomRight:
                        Radius.circular(widget.borderRadius),
                  ),
                ),
                child: const Text(
                  'Change',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.colors, this.icon);
  final ColorScheme colors;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon,
            size: 32,
            color: colors.onSurfaceVariant.withValues(alpha: 0.5)),
        const SizedBox(height: 4),
        Text(
          'Tap to add',
          style: TextStyle(
            fontSize: 10,
            color: colors.onSurfaceVariant.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}
