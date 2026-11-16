import 'package:freezed_annotation/freezed_annotation.dart';

part 'channel_member_response.freezed.dart';
part 'channel_member_response.g.dart';

/// `GET /channels/{channelId}/members` 응답의 사용자 하나. 이름·사진은 id 만 와서 따로
/// 채운다.
///
/// 서버의 이 목록은 채널을 읽을 수 있는 사용자(팀 멤버 중 읽기 권한이 있는 사람, DM 은
/// 대화 상대)라 역할·접속 상태·소유자 같은 정보는 없다.
@freezed
abstract class ChannelMemberResponse with _$ChannelMemberResponse {
  const factory ChannelMemberResponse({
    /// 없으면 fromJson 이 던진다.
    required int userId,
  }) = _ChannelMemberResponse;

  factory ChannelMemberResponse.fromJson(Map<String, dynamic> json) =>
      _$ChannelMemberResponseFromJson(json);
}
