/// `GET /teams` 응답 원소. 내가 속한 팀 하나.
///
/// 게이트웨이 envelope 을 벗긴 `data` 배열의 원소를 받는다(`unwrapListPayload`).
/// `POST /teams` 응답도 화면에서 쓰는 id·이름이 같아 이 모델로 받는다.
class TeamSummaryResponse {
  const TeamSummaryResponse({required this.id, required this.name});

  /// id 가 없으면 채널을 읽을 수도 만들 수도 없으므로 받지 않고 던진다.
  factory TeamSummaryResponse.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) throw const FormatException('팀 응답에 id 가 없습니다.');
    return TeamSummaryResponse(id: id, name: json['name'] as String? ?? '');
  }

  final int id;
  final String name;
}
