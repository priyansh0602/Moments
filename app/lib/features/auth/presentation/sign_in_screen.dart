import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/config/supabase_provider.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/loading_indicator.dart';
import 'package:moments/core/widgets/secondary_button.dart';
import 'package:moments/features/auth/presentation/controllers/auth_controller.dart';

/// Screen for authenticating users exclusively via Google OAuth.
class SignInScreen extends ConsumerStatefulWidget {
  /// Creates a [SignInScreen].
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen>
    with WidgetsBindingObserver {
  String? _errorMessage;
  Timer? _resumeCheckTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _resumeCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final controller = ref.read(authControllerProvider.notifier);
      if (controller.isOAuthInProgress) {
        _resumeCheckTimer?.cancel();
        // Give 1500ms for incoming deep link / session exchange to settle
        _resumeCheckTimer = Timer(const Duration(milliseconds: 1500), () {
          if (!mounted) return;
          final session = ref.read(currentSessionProvider);
          if (session == null && controller.isOAuthInProgress) {
            controller.cancelSignIn();
          }
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _errorMessage = null);

    final success =
        await ref.read(authControllerProvider.notifier).signInWithGoogle();

    if (!success && mounted) {
      final error = ref.read(authControllerProvider).error;
      if (error != null) {
        setState(() {
          _errorMessage = error.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    // Listen for errors from OAuth callback failures
    ref.listen<AsyncValue<void>>(authControllerProvider, (prev, next) {
      if (next.hasError && mounted) {
        setState(() {
          _errorMessage = next.error.toString().replaceFirst('Exception: ', '');
        });
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28.0, vertical: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Brand Logo
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withAlpha(90),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.flash_on_rounded,
                      color: Colors.white,
                      size: 44,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // App Name
                Text(
                  'Moments',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Pitch Subtitle
                Text(
                  'Capture, organize, and play exact song moments from YouTube.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 36),

                // Error Message Banner (if any)
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(24),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.error.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.error,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Single "Continue with Google" Action / Continuous Loading State
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: isLoading
                      ? const Padding(
                          key: ValueKey('loading'),
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: LoadingIndicator(
                            message: 'Signing in with Google...',
                            size: 32,
                          ),
                        )
                      : SecondaryButton(
                          key: const ValueKey('button'),
                          label: 'Continue with Google',
                          icon: Icons.g_mobiledata_rounded,
                          isFullWidth: true,
                          onPressed: _handleGoogleSignIn,
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
