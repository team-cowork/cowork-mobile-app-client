import 'package:freezed_annotation/freezed_annotation.dart';

part 'presigned_upload_request.freezed.dart';
part 'presigned_upload_request.g.dart';

/// `POST /users/me/profile-image/presigned` 요청 본문.
///
/// [contentType] 은 presigned 서명에 들어가므로 실제 업로드 요청의
/// `Content-Type` 과 같아야 한다.
@Freezed(fromJson: false, toJson: true)
abstract class PresignedUploadRequest with _$PresignedUploadRequest {
  @JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
  const factory PresignedUploadRequest({required String contentType}) =
      _PresignedUploadRequest;
}
