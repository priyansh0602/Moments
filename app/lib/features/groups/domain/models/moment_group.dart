import 'package:freezed_annotation/freezed_annotation.dart';

part 'moment_group.freezed.dart';

/// Immutable representation of a Moment Collection / Group.
@freezed
abstract class MomentGroup with _$MomentGroup {
  const factory MomentGroup({
    required String id,
    required String name,
    required int momentCount,
    @Default(<String>[]) List<String> thumbnailUrls,
    String? description,
  }) = _MomentGroup;
}
