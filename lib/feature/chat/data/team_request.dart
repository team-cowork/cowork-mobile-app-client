/// `POST /teams` 요청 본문.
class CreateTeamRequest {
  const CreateTeamRequest({required this.name, this.description});

  final String name;

  /// 팀 소개. 없으면 보내지 않는다.
  final String? description;

  Map<String, dynamic> toJson() => {
    'name': name,
    if (description != null) 'description': description,
  };
}
