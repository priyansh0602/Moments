import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:moments/core/router/app_routes.dart';
import 'package:moments/core/theme/app_colors.dart';
import 'package:moments/features/auth/presentation/controllers/auth_controller.dart';
import 'package:moments/features/profile/presentation/providers/profile_provider.dart';

/// Screen displaying user identity, snippet stats, and profile links.
///
/// Subscribes to real user profile data from Supabase via [currentUserProfileProvider].
class ProfileScreen extends ConsumerWidget {
  /// Creates a [ProfileScreen].
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);
    final profile = profileAsync.value;

    final displayName = profile?.displayName?.isNotEmpty == true
        ? profile!.displayName!
        : (profile?.username ?? 'Curator');
    final username = profile?.username ?? 'user';
    final momentsCount = profile?.momentsCount.toString() ?? '0';
    final bio = profile?.bio ?? 'Late night music lover and moment creator.';

    final avatarInitial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'M';
    final avatarUrl = profile?.avatarUrl;
    List<Color> avatarGradient = const [AppColors.primary, AppColors.accent];
    IconData? avatarIcon;
    if (avatarUrl != null && avatarUrl.startsWith('avatar:')) {
      final key = avatarUrl.replaceFirst('avatar:', '');
      switch (key) {
        case 'electric_violet':
          avatarGradient = const [Color(0xFF8A2BE2), Color(0xFF4A00E0)];
          avatarIcon = Icons.headphones_rounded;
          break;
        case 'neon_synth':
          avatarGradient = const [Color(0xFF00F2FE), Color(0xFF4FACFE)];
          avatarIcon = Icons.graphic_eq_rounded;
          break;
        case 'amber_glow':
          avatarGradient = const [Color(0xFFFFB800), Color(0xFFFF5E3A)];
          avatarIcon = Icons.flash_on_rounded;
          break;
        case 'night_void':
          avatarGradient = const [Color(0xFF2E2B3E), Color(0xFF16151E)];
          avatarIcon = Icons.nightlight_round;
          break;
        case 'sunset_coral':
        default:
          avatarGradient = const [AppColors.primary, AppColors.accent];
          avatarIcon = Icons.music_note_rounded;
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit Profile',
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Column(
          children: [
            // User Avatar & Name Header
            Center(
              child: Column(
                children: [
                  Container(
                    width: 86,
                    height: 86,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: avatarGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: avatarGradient.first.withAlpha(80),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: avatarIcon != null
                          ? Icon(avatarIcon, color: Colors.white, size: 40)
                          : Text(
                              avatarInitial,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    displayName,
                    style: theme.textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@$username',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (bio.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        bio,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stat Cards Row with real momentsCount from Supabase
            Row(
              children: [
                _buildStatCard(context, momentsCount, 'Moments'),
                const SizedBox(width: 10),
                _buildStatCard(context, '0', 'Groups'),
                const SizedBox(width: 10),
                _buildStatCard(context, '0', 'Plays'),
              ],
            ),
            const SizedBox(height: 28),

            // Section Links
            Card(
              child: Column(
                children: [
                  _buildProfileTile(
                    context,
                    icon: Icons.edit_note_rounded,
                    title: 'Edit Profile & Style',
                    subtitle: 'Customize handle, avatar style, display name, and bio',
                    onTap: () => context.push(AppRoutes.editProfile),
                  ),
                  const Divider(),
                  _buildProfileTile(
                    context,
                    icon: Icons.bookmark_outline_rounded,
                    title: 'Your Moments',
                    subtitle: '$momentsCount saved snippets',
                    onTap: () => context.go(AppRoutes.moments),
                  ),
                  const Divider(),
                  _buildProfileTile(
                    context,
                    icon: Icons.folder_special_outlined,
                    title: 'Your Groups',
                    subtitle: 'Curated playlists and snippet groups',
                    onTap: () => context.go(AppRoutes.groups),
                  ),
                  const Divider(),
                  _buildProfileTile(
                    context,
                    icon: Icons.logout_rounded,
                    title: 'Sign Out',
                    subtitle: 'Log out of this device',
                    isDestructive: true,
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out of Moments?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              await ref.read(authControllerProvider.notifier).signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String value, String label) {
    final theme = Theme.of(context);
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14.0),
          child: Column(
            children: [
              Text(
                value,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primary,
      ),
      title: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: isDestructive ? AppColors.error : null,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}
