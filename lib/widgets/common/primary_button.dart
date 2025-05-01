// lib/widgets/common/primary_button.dart
import 'package:flutter/material.dart';

enum ButtonVariant { primary, secondary, success, warning, danger }

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final bool fullWidth;
  final ButtonVariant variant;
  final IconData? icon;

  const PrimaryButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.fullWidth = false,
    this.variant = ButtonVariant.primary,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(context),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          disabledBackgroundColor: _getBackgroundColor(context).withOpacity(0.6),
          disabledForegroundColor: Colors.white70,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 20),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBackgroundColor(BuildContext context) {
    if (backgroundColor != null) return backgroundColor!;

    switch (variant) {
      case ButtonVariant.primary:
        return Theme.of(context).colorScheme.primary;
      case ButtonVariant.secondary:
        return Theme.of(context).colorScheme.secondary;
      case ButtonVariant.success:
        return Colors.green;
      case ButtonVariant.warning:
        return Colors.amber;
      case ButtonVariant.danger:
        return Colors.red;
    }
  }
}