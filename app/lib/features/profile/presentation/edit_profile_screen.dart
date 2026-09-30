import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/primary_button.dart';
import 'package:moments/features/profile/data/profile_repository.dart';
import 'package:moments/features/profile/presentation/providers/profile_provider.dart';

class _AvatarOption {
  const _AvatarOption(this.name, this.colors, this.icon);
  final String name;
  final List<Color> colors;
  final IconData icon;
}

const List<_AvatarOption> _avatarOptions = [
  _AvatarOption('Sunset Coral', [AppColors.primary, AppColors.accent], Icons.music_note_rounded),
  _AvatarOption('Electric Violet', [Color(0xFF8A2BE2), Color(0xFF4A00E0)], Icons.headphones_rounded),
  _AvatarOption('Neon Synth', [Color(0xFF00F2FE), Color(0xFF4FACFE)], Icons.graphic_eq_rounded),
  _AvatarOption('Amber Glow', [Color(0xFFFFB800), Color(0xFFFF5E3A)], Icons.flash_on_rounded),
  _AvatarOption('Night Void', [Color(0xFF2E2B3E), Color(0xFF16151E)], Icons.nightlight_round),
];

/// Screen allowing users to update their avatar style, display name, username, and bio.
class EditProfileScreen extends ConsumerStatefulWidget {
  /// Creates an [EditProfileScreen].
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _usernameController;
  late final TextEditingController _displayNameController;
  late final TextEditingController _bioController;

  Timer? _debounceTimer;
  bool _isCheckingAvailability = false;
  bool? _isUsernameAvailable;
  String? _usernameValidationError;
  bool _isSaving = false;
  String? _initialUsername;
  int _selectedAvatarIndex = 0;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    _initialUsername = profile?.username ?? '';
    _usernameController = TextEditingController(text: _initialUsername);
    _displayNameController = TextEditingController(text: profile?.displayName ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');

    final currentAvatar = profile?.avatarUrl;
    if (currentAvatar != null && currentAvatar.startsWith('avatar:')) {
      final key = currentAvatar.replaceFirst('avatar:', '');
      final idx = _avatarOptions.indexWhere(
        (o) => o.name.toLowerCase().replaceAll(' ', '_') == key,
      );
      if (idx != -1) _selectedAvatarIndex = idx;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameController.dispose();
    _displayNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String value) {
    _debounceTimer?.cancel();
    final clean = value.trim().toLowerCase();

    // If unchanged, it's their own username
    if (clean == _initialUsername?.toLowerCase()) {
      setState(() {
        _isCheckingAvailability = false;
        _isUsernameAvailable = true;
        _usernameValidationError = null;
      });
      return;
    }

    if (clean.length < 3) {
      setState(() {
        _isCheckingAvailability = false;
        _isUsernameAvailable = null;
        _usernameValidationError = 'Username must be at least 3 characters.';
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
      final profile = ref.read(currentUserProfileProvider).value;
      final isAvailable = await ref
          .read(profileRepositoryProvider)
          .isUsernameAvailable(clean, excludeUserId: profile?.id);

      if (mounted) {
        setState(() {
          _isCheckingAvailability = false;
          _isUsernameAvailable = isAvailable;
        });
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isUsernameAvailable == false) return;

    setState(() => _isSaving = true);

    try {
      final selectedAvatar =
          'avatar:${_avatarOptions[_selectedAvatarIndex].name.toLowerCase().replaceAll(' ', '_')}';

      await ref.read(currentUserProfileProvider.notifier).updateProfile(
            username: _usernameController.text.trim().toLowerCase(),
            displayName: _displayNameController.text.trim(),
            bio: _bioController.text.trim(),
            avatarUrl: selectedAvatar,
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = ref.watch(currentUserProfileProvider).value;
    final isPlaceholder = profile?.isPlaceholderUsername ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile & Style'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info banner if user still has placeholder handle
                if (isPlaceholder) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withAlpha(70)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            color: AppColors.accent, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "You're currently using an auto-generated handle. Choose a custom handle and style below!",
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Avatar Style Selector (From Pick Your Handle)
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
                              color: _avatarOptions[_selectedAvatarIndex]
                                  .colors
                                  .first
                                  .withAlpha(90),
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
                      const SizedBox(height: 10),
                      Text(
                        _avatarOptions[_selectedAvatarIndex].name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_avatarOptions.length, (index) {
                          final option = _avatarOptions[index];
                          final isSelected = index == _selectedAvatarIndex;
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _selectedAvatarIndex = index),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 5),
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(colors: option.colors),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Display Name Field
                TextFormField(
                  controller: _displayNameController,
                  enabled: !_isSaving,
                  decoration: const InputDecoration(
                    labelText: 'Display Name',
                    hintText: 'e.g. Priyansh',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),
                const SizedBox(height: 16),

                // Username Field
                TextFormField(
                  controller: _usernameController,
                  enabled: !_isSaving,
                  autocorrect: false,
                  onChanged: _onUsernameChanged,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    prefixIcon: const Icon(Icons.alternate_email_rounded),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: _buildUsernameStatusIcon(),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Username cannot be empty.';
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
                if (_usernameValidationError != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    _usernameValidationError!,
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: AppColors.error),
                  ),
                ],
                const SizedBox(height: 16),

                // Bio Field
                TextFormField(
                  controller: _bioController,
                  enabled: !_isSaving,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Bio',
                    hintText: 'Tell others about your musical taste...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 32),

                // Save Button
                PrimaryButton(
                  label: 'Save Changes',
                  isLoading: _isSaving,
                  isFullWidth: true,
                  onPressed: _handleSave,
                ),
              ],
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
    if (_isUsernameAvailable == true &&
        _usernameController.text != _initialUsername) {
      return const Icon(Icons.check_circle_rounded,
          color: AppColors.success, size: 20);
    }
    if (_isUsernameAvailable == false) {
      return const Icon(Icons.cancel_rounded,
          color: AppColors.error, size: 20);
    }
    return const SizedBox.shrink();
  }
}
