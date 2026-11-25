import 'package:freezed_annotation/freezed_annotation.dart';

part 'webhook_author_response.freezed.dart';
part 'webhook_author_response.g.dart';

/// 웹훅이 보낸 메시지의 작성자. 사람이 아니라서 사용자 id 로 이름을 찾지 않는다.
@freezed
abstract class WebhookAuthorResponse with _$WebhookAuthorResponse {
  @JsonSerializable(checked: true)
  const factory WebhookAuthorResponse({
    /// 웹훅 id. 사용자 id 와 다른 번호 체계다.
    required int id,
    @Default('') String name,
    String? avatarUrl,
  }) = _WebhookAuthorResponse;

  factory WebhookAuthorResponse.fromJson(Map<String, dynamic> json) =>
      _$WebhookAuthorResponseFromJson(json);
}
