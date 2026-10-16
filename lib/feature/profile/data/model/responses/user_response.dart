import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_response.freezed.dart';
part 'user_response.g.dart';

/// `/users/*` 응답 본문.
///
/// 조회·수정·상태 변경이 모두 같은 사용자 표현을 돌려주므로 응답 모델은 하나다.
/// 게이트웨이 envelope 을 벗긴 `data` 를 받는다(`unwrapPayload`).
///
/// 서버가 값 없음을 null 로도, 빈 문자열로도 내려주기 때문에 여기서는 받은 그대로
/// 담고, "없음"으로 볼지는 화면 모델이 정한다.
@freezed
abstract class UserResponse with _$UserResponse {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory UserResponse({
    /// 사용자 id. 회의록 소유 판별에 쓴다.
    int? id,
    String? name,
    String? email,
    String? nickname,

    /// 접속 상태. 서버가 `offline` 처럼 소문자로 내려준다.
    String? status,
    String? statusMessage,

    /// 상태 만료 시각(ISO8601). 아직 화면에서 쓰지 않아 문자열 그대로 둔다.
    String? statusExpiresAt,

    /// 자기소개.
    String? description,

    /// 계정 설명. `description` 과 별개 필드다.
    String? accountDescription,

    /// 직군 (예: 프론트엔드 개발자).
    String? specialty,
    String? major,

    /// 학번 코드 (예: 3413).
    String? studentNumber,
    String? studentRole,
    String? githubId,
    String? profileImageUrl,
    String? sex,

    /// 역할 목록. 없으면 빈 배열로 온다.
    @Default([]) List<String> roles,
  }) = _UserResponse;

  factory UserResponse.fromJson(Map<String, dynamic> json) =>
      _$UserResponseFromJson(json);
}
