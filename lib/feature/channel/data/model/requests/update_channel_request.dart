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
  }) = _UpdateChannelRequest;
}
