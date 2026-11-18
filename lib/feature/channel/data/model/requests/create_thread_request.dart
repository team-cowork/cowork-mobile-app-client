import 'package:freezed_annotation/freezed_annotation.dart';

part 'create_thread_request.freezed.dart';
part 'create_thread_request.g.dart';

/// `POST /channels/{channelId}/threads` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class CreateThreadRequest with _$CreateThreadRequest {
  const factory CreateThreadRequest({
    required String name,
    required String parentMessageId,
  }) = _CreateThreadRequest;
}
