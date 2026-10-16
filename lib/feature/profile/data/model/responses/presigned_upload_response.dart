import 'package:freezed_annotation/freezed_annotation.dart';

part 'presigned_upload_response.freezed.dart';
part 'presigned_upload_response.g.dart';

/// `POST /users/me/profile-image/presigned` 응답.
///
/// [uploadUrl] 은 스토리지로 바로 가는 절대 URL 이고, [objectKey] 는 업로드 뒤
/// confirm 에 되돌려 보낼 값이다.
@freezed
abstract class PresignedUploadResponse with _$PresignedUploadResponse {
  // 빠진 필드도 빈 값으로 받은 뒤 fromJson 에서 한꺼번에 검사한다.
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory PresignedUploadResponse({
    @Default('') String objectKey,
    @Default('') String uploadUrl,
  }) = _PresignedUploadResponse;

  /// 둘 중 하나라도 비면 던진다. 빈 URL 로 올리면 업로드가 스토리지가 아니라
  /// API 게이트웨이로 날아가고, 실패가 한참 뒤에야 엉뚱한 모습으로 드러난다.
  factory PresignedUploadResponse.fromJson(Map<String, dynamic> json) {
    final response = _$PresignedUploadResponseFromJson(json);
    if (response.objectKey.isEmpty || response.uploadUrl.isEmpty) {
      throw const FormatException(
        'presigned 응답에 object_key/upload_url 이 없습니다.',
      );
    }
    return response;
  }
}
