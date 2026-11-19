import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_channel_request.freezed.dart';
part 'update_channel_request.g.dart';

/// `PATCH /channels/{channelId}` 요청 본문.
///
/// 서버는 보낸 필드만 바꾼다. 안 보낸(null) 필드는 본문에서 빼서 기존 값을 유지한다.
@Freezed(fromJson: false, toJson: true)
abstract class UpdateChannelRequest with _$UpdateChannelRequest {
  @JsonSerializable(includeIfNull: false)
  const factory UpdateChannelRequest({
    String? name,
    String? description,
    bool? isPrivate,

    /// 채널을 넣을 프로젝트. 채널 생성 요청에는 이 필드가 없어 만든 뒤 붙인다.
    int? projectId,
  }) = _UpdateChannelRequest;
}
