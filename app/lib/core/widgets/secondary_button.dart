import 'package:flutter/material.dart';

/// Clean outlined/secondary action button styled for Moments design system.
class SecondaryButton extends StatelessWidget {
  /// Creates a [SecondaryButton].
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.isFullWidth = false,
  });

  /// The text displayed inside the button.
  final String label;

  /// Callback when the button is tapped.
  final VoidCallback? onPressed;

  /// Optional leading icon.
  final IconData? icon;

  /// Whether the button should stretch to full parent width.
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final buttonContent = Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: theme.colorScheme.onSurface),
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w600,
            fontSize: 14,
            letterSpacing: 0.1,
          ),
        ),
      ],
    );

    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: theme.colorScheme.outline,
          width: 1.2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
      ),
      child: buttonContent,
    );

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }
    return button;
  }
}
