import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/core/widgets/primary_button.dart';
import 'package:moments/features/profile/data/profile_repository.dart';
import 'package:moments/features/profile/presentation/providers/profile_provider.dart';

/// Screen allowing users to update their display name, username, bio, and avatar.
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

  @override
  void initState() {
    super.initState();
    final profile = ref.read(currentUserProfileProvider).value;
    _initialUsername = profile?.username ?? '';
    _usernameController = TextEditingController(text: _initialUsername);
    _displayNameController = TextEditingController(text: profile?.displayName ?? '');
    _bioController = TextEditingController(text: profile?.bio ?? '');
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
      await ref.read(currentUserProfileProvider.notifier).updateProfile(
            username: _usernameController.text.trim().toLowerCase(),
            displayName: _displayNameController.text.trim(),
            bio: _bioController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            duration: Duration(seconds: 1),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
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
                    style: theme.textTheme.bodySmall?.copyWith(color: AppColors.error),
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
    if (_isUsernameAvailable == true && _usernameController.text != _initialUsername) {
      return const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 20);
    }
    if (_isUsernameAvailable == false) {
      return const Icon(Icons.cancel_rounded, color: AppColors.error, size: 20);
    }
    return const SizedBox.shrink();
  }
}
