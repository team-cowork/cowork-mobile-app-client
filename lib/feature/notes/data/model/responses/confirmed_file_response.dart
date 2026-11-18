import 'package:freezed_annotation/freezed_annotation.dart';

part 'confirmed_file_response.freezed.dart';
part 'confirmed_file_response.g.dart';

/// `POST /chat/channels/{channelId}/files/confirm` 응답. 회의록에 붙일 값만 옮긴다.
@freezed
abstract class ConfirmedFileResponse with _$ConfirmedFileResponse {
  // fromJson 이 검사를 하느라 블록 본문이라, freezed 가 JSON 지원을 알아보도록
  // 직접 붙인다.
  @JsonSerializable()
  const factory ConfirmedFileResponse({
    /// 확정 키(`chat-files/...`). 회의록 `attachments` 에는 이 키를 보낸다.
    @Default('') String objectKey,

    /// 서버가 기록한 파일 이름. 업로드 주소를 받을 때 보낸 이름이다.
    @Default('') String name,
  }) = _ConfirmedFileResponse;

  /// 확정 키가 비면 던진다. 빈 키를 회의록에 보내면 저장할 때가 되어서야 400 이 난다.
  factory ConfirmedFileResponse.fromJson(Map<String, dynamic> json) {
    final response = _$ConfirmedFileResponseFromJson(json);
    if (response.objectKey.isEmpty) {
      throw const FormatException('업로드 확인 응답에 objectKey 가 없다');
    }
    return response;
  }
}
