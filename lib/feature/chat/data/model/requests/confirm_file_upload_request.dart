import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_file_upload_request.freezed.dart';
part 'confirm_file_upload_request.g.dart';

/// `POST /chat/channels/{channelId}/files/confirm` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class ConfirmFileUploadRequest with _$ConfirmFileUploadRequest {
  const factory ConfirmFileUploadRequest({
    /// 업로드 주소를 받을 때 함께 온 임시 키.
    required String objectKey,
  }) = _ConfirmFileUploadRequest;
}
