import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moments/core/config/supabase_provider.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/primary_button.dart';
import 'package:moments/features/profile/data/profile_repository.dart';
import 'package:moments/features/profile/presentation/providers/profile_provider.dart';

/// Screen displayed to newly authenticated users to set a unique username,
/// optional display name, and select a profile avatar.
class OnboardingUsernameScreen extends ConsumerStatefulWidget {
  /// Creates an [OnboardingUsernameScreen].
  const OnboardingUsernameScreen({super.key});

  @override
  ConsumerState<OnboardingUsernameScreen> createState() =>
      _OnboardingUsernameScreenState();
}

class _OnboardingUsernameScreenState
    extends ConsumerState<OnboardingUsernameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _displayNameController = TextEditingController();

  Timer? _debounceTimer;
  bool _isCheckingAvailability = false;
  bool? _isUsernameAvailable;
  String? _usernameValidationError;
  bool _isSubmitting = false;

  int _selectedAvatarIndex = 0;
  static const List<_AvatarOption> _avatarOptions = [
    _AvatarOption('Sunset Coral', [AppColors.primary, AppColors.accent], Icons.music_note_rounded),
    _AvatarOption('Electric Violet', [Color(0xFF8A2BE2), Color(0xFF4A00E0)], Icons.headphones_rounded),
    _AvatarOption('Neon Synth', [Color(0xFF00F2FE), Color(0xFF4FACFE)], Icons.graphic_eq_rounded),
    _AvatarOption('Amber Glow', [Color(0xFFFFB800), Color(0xFFFF5E3A)], Icons.flash_on_rounded),
    _AvatarOption('Night Void', [Color(0xFF2E2B3E), Color(0xFF16151E)], Icons.nightlight_round),
  ];

  @override
  void initState() {
    super.initState();
    // Pre-populate display name if user metadata had it
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentAuthUserProvider);
      final metaName = user?.userMetadata?['name'] ?? user?.userMetadata?['full_name'];
      if (metaName != null && metaName.toString().isNotEmpty) {
        _displayNameController.text = metaName.toString();
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameController.dispose();
    _displayNameController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounceTimer?.cancel();
    final clean = value.trim().toLowerCase();

    if (clean.length < 3) {
      setState(() {
        _isCheckingAvailability = false;
        _isUsernameAvailable = null;
        _usernameValidationError = clean.isEmpty ? null : 'At least 3 characters required.';
      });
      return;
    }

    final validCharacters = RegExp(r'^[a-z0-9_]+$');
    if (!validCharacters.hasMatch(clean)) {
      setState(() {
        _isCheckingAvailability = false;
        _isUsernameAvailable = null;
        _usernameValidationError = 'Only lowercase letters, numbers, and underscores.';
      });
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
      _usernameValidationError = null;
    });

    _debounceTimer = Timer(const Duration(milliseconds: 350), () async {
      final user = ref.read(currentAuthUserProvider);
      final isAvailable = await ref
          .read(profileRepositoryProvider)
          .isUsernameAvailable(clean, excludeUserId: user?.id);

      if (mounted) {
        setState(() {
          _isCheckingAvailability = false;
          _isUsernameAvailable = isAvailable;
        });
      }
    });
  }

  Future<void> _handleComplete() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isUsernameAvailable == false) return;

    final user = ref.read(currentAuthUserProvider);
    if (user == null) return;

    setState(() => _isSubmitting = true);

    try {
      final selectedAvatar = 'avatar:${_avatarOptions[_selectedAvatarIndex].name.toLowerCase().replaceAll(' ', '_')}';
      await ref.read(profileRepositoryProvider).updateProfile(
            id: user.id,
            username: _usernameController.text.trim().toLowerCase(),
            displayName: _displayNameController.text.trim().isNotEmpty
                ? _displayNameController.text.trim()
                : null,
            avatarUrl: selectedAvatar,
          );

      // Force refresh of the profile provider so the router redirects to /search
      await ref.read(currentUserProfileProvider.notifier).refresh();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Pick Your Handle',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Choose a unique username and avatar for your Moments profile.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Avatar Picker
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: _avatarOptions[_selectedAvatarIndex].colors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _avatarOptions[_selectedAvatarIndex].colors.first.withAlpha(90),
                                blurRadius: 20,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            _avatarOptions[_selectedAvatarIndex].icon,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(_avatarOptions.length, (index) {
                            final option = _avatarOptions[index];
                            final isSelected = index == _selectedAvatarIndex;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedAvatarIndex = index),
                              child: Container(
                                margin: const EdgeInsets.symmetric(horizontal: 5),
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(colors: option.colors),
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Username Field
                  TextFormField(
                    controller: _usernameController,
                    autocorrect: false,
                    enabled: !_isSubmitting,
                    onChanged: _onUsernameChanged,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'e.g. synth_collector',
                      prefixIcon: const Icon(Icons.alternate_email_rounded),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: _buildUsernameStatusIcon(),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Username is required.';
                      }
                      if (_usernameValidationError != null) {
                        return _usernameValidationError;
                      }
                      if (_isUsernameAvailable == false) {
                        return 'This username is already taken.';
                      }
                      return null;
                    },
                  ),

                  // Status text helper
                  if (_usernameValidationError != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      _usernameValidationError!,
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ] else if (_isUsernameAvailable == true) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Username is available!',
                      style: theme.textTheme.bodySmall?.copyWith(color: AppColors.success),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Display Name Field
                  TextFormField(
                    controller: _displayNameController,
                    enabled: !_isSubmitting,
                    decoration: const InputDecoration(
                      labelText: 'Display Name (optional)',
                      hintText: 'e.g. Elena Rostova',
                      prefixIcon: Icon(Icons.badge_outlined),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Submit Button
                  PrimaryButton(
                    label: 'Complete Setup',
                    isLoading: _isSubmitting,
                    isFullWidth: true,
                    onPressed: _isUsernameAvailable == true ? _handleComplete : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameStatusIcon() {
    if (_isCheckingAvailability) {
      return const SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(strokeWidth: 2.0),
      );
    }
    if (_isUsernameAvailable == true) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20);
    }
    if (_isUsernameAvailable == false) {
      return const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20);
    }
    return const SizedBox.shrink();
  }
}

class _AvatarOption {
  const _AvatarOption(this.name, this.colors, this.icon);
  final String name;
  final List<Color> colors;
  final IconData icon;
}
