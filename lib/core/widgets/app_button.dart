/// AppButton — unified pressable button used throughout the app.
///
/// Features:
///   - Press scale feedback (0.96)
///   - Loading state with spinner
///   - Disabled state
///   - Optional leading icon
library app_button;

import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';

class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isDisabled = false,
    this.style = AppButtonStyle.filled,
    this.color,
    this.width,
    this.height = 52,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isDisabled;
  final AppButtonStyle style;
  final Color? color;
  final double? width;
  final double height;

  @override
  State<AppButton> createState() => _AppButtonState();
}

enum AppButtonStyle { filled, outlined, ghost }

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: AppMotion.micro,
      lowerBound: AppMotion.pressedScale,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = _ctrl;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    if (_isInteractive) _ctrl.animateTo(AppMotion.pressedScale);
  }

  void _onTapUp(_) {
    if (_isInteractive) _ctrl.animateTo(1.0);
  }

  void _onTapCancel() {
    if (_isInteractive) _ctrl.animateTo(1.0);
  }

  bool get _isInteractive =>
      !widget.isDisabled && !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final fillColor = widget.color ?? AppColors.primary;
    final onFillColor = cs.onPrimary;

    Color bgColor;
    Color fgColor;
    Border? border;

    switch (widget.style) {
      case AppButtonStyle.filled:
        bgColor = _isInteractive ? fillColor : AppColors.divider;
        fgColor = _isInteractive ? onFillColor : AppColors.textMuted;
        break;
      case AppButtonStyle.outlined:
        bgColor = Colors.transparent;
        fgColor = _isInteractive ? fillColor : AppColors.textMuted;
        border = Border.all(
          color: _isInteractive ? fillColor : AppColors.divider,
          width: 1.5,
        );
        break;
      case AppButtonStyle.ghost:
        bgColor = Colors.transparent;
        fgColor = _isInteractive ? fillColor : AppColors.textMuted;
        break;
    }

    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) => Transform.scale(
        scale: _scale.value,
        child: child,
      ),
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: _isInteractive ? widget.onPressed : null,
        child: Semantics(
          button: true,
          enabled: _isInteractive,
          label: widget.label,
          child: AnimatedContainer(
            duration: AppMotion.micro,
            width: widget.width ?? double.infinity,
            height: widget.height,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(AppRadius.button),
              border: border,
            ),
            child: Center(
              child: widget.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(fgColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(widget.icon, color: fgColor, size: 18),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          widget.label,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: fgColor,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
