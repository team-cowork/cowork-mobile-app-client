import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirm_profile_image_request.freezed.dart';
part 'confirm_profile_image_request.g.dart';

/// `POST /users/me/profile-image/confirm` 요청 본문.
@Freezed(fromJson: false, toJson: true)
abstract class ConfirmProfileImageRequest with _$ConfirmProfileImageRequest {
  @JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
  const factory ConfirmProfileImageRequest({
    /// presigned 발급 때 받은 값.
    required String objectKey,
  }) = _ConfirmProfileImageRequest;
}
