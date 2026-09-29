import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Strongly-typed model representing a user profile from the `public.profiles` table.
@freezed
abstract class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String id,
    required String username,
    @JsonKey(name: 'display_name') String? displayName,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    String? bio,
    @JsonKey(name: 'moments_count') @Default(0) int momentsCount,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _UserProfile;

  const UserProfile._();

  /// Deserializes a [UserProfile] from Supabase JSON map.
  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  /// Whether this profile still has an auto-generated placeholder username.
  ///
  /// Profiles created by the `handle_new_user()` trigger follow the pattern
  /// `user_<shortid>` or `<emailprefix>_<5chars>`. If true, user should be
  /// prompted to complete onboarding.
  bool get isPlaceholderUsername {
    if (username.startsWith('user_')) return true;
    final regex = RegExp(r'^.+_[a-zA-Z0-9]{5}$');
    return regex.hasMatch(username);
  }
}
