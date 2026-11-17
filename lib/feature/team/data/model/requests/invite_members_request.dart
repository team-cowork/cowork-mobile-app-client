import 'package:freezed_annotation/freezed_annotation.dart';

part 'invite_members_request.freezed.dart';
part 'invite_members_request.g.dart';

/// `POST /teams/{teamId}/members` 요청 본문.
///
/// 서버는 한 번에 100명까지 받고, 이미 멤버인 사람은 건너뛴다.
@Freezed(fromJson: false, toJson: true)
abstract class InviteMembersRequest with _$InviteMembersRequest {
  const factory InviteMembersRequest({required List<int> userIds}) =
      _InviteMembersRequest;
}
