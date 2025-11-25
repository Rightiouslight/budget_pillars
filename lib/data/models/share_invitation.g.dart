// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'share_invitation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShareInvitationImpl _$$ShareInvitationImplFromJson(
  Map<String, dynamic> json,
) => _$ShareInvitationImpl(
  id: json['id'] as String,
  fromUserId: json['fromUserId'] as String,
  fromUserEmail: json['fromUserEmail'] as String,
  toUserEmail: json['toUserEmail'] as String,
  budgetMonthKey: json['budgetMonthKey'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  status: json['status'] as String? ?? 'pending',
  canWrite: json['canWrite'] as bool? ?? false,
);

Map<String, dynamic> _$$ShareInvitationImplToJson(
  _$ShareInvitationImpl instance,
) => <String, dynamic>{
  'id': instance.id,
  'fromUserId': instance.fromUserId,
  'fromUserEmail': instance.fromUserEmail,
  'toUserEmail': instance.toUserEmail,
  'budgetMonthKey': instance.budgetMonthKey,
  'createdAt': instance.createdAt.toIso8601String(),
  'status': instance.status,
  'canWrite': instance.canWrite,
};
