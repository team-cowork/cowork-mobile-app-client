import 'package:freezed_annotation/freezed_annotation.dart';

part 'edit_message_request.freezed.dart';
part 'edit_message_request.g.dart';

/// `PATCH /chat/channels/{channelId}/messages/{messageId}` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class EditMessageRequest with _$EditMessageRequest {
  @JsonSerializable(createFactory: false)
  const factory EditMessageRequest({required String content}) =
      _EditMessageRequest;
}
