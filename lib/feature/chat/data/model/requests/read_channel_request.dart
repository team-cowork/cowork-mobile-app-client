import 'package:freezed_annotation/freezed_annotation.dart';

part 'read_channel_request.freezed.dart';
part 'read_channel_request.g.dart';

/// `POST /chat/channels/{channelId}/read` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class ReadChannelRequest with _$ReadChannelRequest {
  @JsonSerializable(createFactory: false)
  const factory ReadChannelRequest({required String lastReadMessageId}) =
      _ReadChannelRequest;
}
