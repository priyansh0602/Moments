import 'package:flutter/material.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/primary_button.dart';

/// Reusable empty state view with an illustrative icon, title, subtitle,
/// and an optional call-to-action button.
class EmptyState extends StatelessWidget {
  /// Creates an [EmptyState].
  const EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  /// The icon representing the state (e.g. music note, search off, folder).
  final IconData icon;

  /// Main headline.
  final String title;

  /// Secondary descriptive text explaining what to do next.
  final String subtitle;

  /// Optional label for the action button.
  final String? actionLabel;

  /// Optional callback triggered when the action button is pressed.
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withAlpha(24),
                border: Border.all(
                  color: AppColors.primary.withAlpha(60),
                  width: 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 38,
                color: AppColors.primaryLight,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              PrimaryButton(
                label: actionLabel!,
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
