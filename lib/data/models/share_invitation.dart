import 'package:freezed_annotation/freezed_annotation.dart';

part 'share_invitation.freezed.dart';
part 'share_invitation.g.dart';

@freezed
class ShareInvitation with _$ShareInvitation {
  const factory ShareInvitation({
    required String id,
    required String fromUserId,
    required String fromUserEmail,
    required String toUserEmail,
    required String budgetMonthKey,
    required DateTime createdAt,
    @Default('pending') String status, // pending, accepted, rejected
    @Default(false) bool canWrite,
  }) = _ShareInvitation;

  factory ShareInvitation.fromJson(Map<String, dynamic> json) =>
      _$ShareInvitationFromJson(json);
}
