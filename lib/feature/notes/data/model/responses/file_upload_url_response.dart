import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_upload_url_response.freezed.dart';
part 'file_upload_url_response.g.dart';

/// `POST /chat/channels/{channelId}/files/presigned-url` 응답.
///
/// [uploadUrl] 은 게이트웨이의 스토리지 중계(`/api/storage/...`)로 가는 절대 URL 이다.
@freezed
abstract class FileUploadUrlResponse with _$FileUploadUrlResponse {
  // 빠진 필드도 빈 값으로 받은 뒤 fromJson 에서 한꺼번에 검사한다.
  // fromJson 이 검사를 하느라 블록 본문이라, freezed 가 JSON 지원을 알아보도록
  // 직접 붙인다.
  @JsonSerializable()
  const factory FileUploadUrlResponse({
    /// 업로드 확인에 되돌려 보낼 임시 키.
    @Default('') String objectKey,
    @Default('') String uploadUrl,

    /// PUT 에 그대로 실어야 하는 헤더. 서명에 `Content-Type` 이 들어 있다.
    @Default({}) Map<String, String> headers,
  }) = _FileUploadUrlResponse;

  /// 키나 주소가 비면 던진다. 빈 주소로 올리면 요청이 스토리지가 아니라 API
  /// 게이트웨이로 가서, 실패가 엉뚱한 모습으로 드러난다.
  factory FileUploadUrlResponse.fromJson(Map<String, dynamic> json) {
    final response = _$FileUploadUrlResponseFromJson(json);
    if (response.objectKey.isEmpty || response.uploadUrl.isEmpty) {
      throw const FormatException('업로드 주소 응답에 objectKey/uploadUrl 이 없다');
    }
    return response;
  }
}
