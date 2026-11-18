import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_icon_upload_response.freezed.dart';
part 'team_icon_upload_response.g.dart';

/// `POST /teams/icon/presigned` 응답.
///
/// [uploadUrl] 은 스토리지로 바로 가는 절대 URL 이고, [objectKey] 는 업로드 뒤
/// `POST /teams/icon/confirm` 에 되돌려 보낼 값이다.
@freezed
abstract class TeamIconUploadResponse with _$TeamIconUploadResponse {
  // 빠진 필드도 빈 값으로 받은 뒤 fromJson 에서 한꺼번에 검사한다. fromJson 을 직접
  // 써서 freezed 가 json_serializable 을 붙이지 않으므로 명시한다.
  @JsonSerializable()
  const factory TeamIconUploadResponse({
    @Default('') String uploadUrl,
    @Default('') String objectKey,
  }) = _TeamIconUploadResponse;

  /// 둘 중 하나라도 비면 던진다. 빈 URL 로 올리면 업로드가 스토리지가 아니라
  /// API 게이트웨이로 날아가고, 실패가 한참 뒤에야 엉뚱한 모습으로 드러난다.
  factory TeamIconUploadResponse.fromJson(Map<String, dynamic> json) {
    final response = _$TeamIconUploadResponseFromJson(json);
    if (response.uploadUrl.isEmpty || response.objectKey.isEmpty) {
      throw const FormatException('presigned 응답에 uploadUrl/objectKey 가 없습니다.');
    }
    return response;
  }
}
