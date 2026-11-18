import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_team_request.freezed.dart';
part 'update_team_request.g.dart';

/// `PATCH /teams/{teamId}` 요청 본문.
///
/// 서버는 보낸 필드만 바꾼다. 안 보낸(null) 필드는 본문에서 빼서 기존 값을 유지한다.
/// 설명을 지우려면 빈 문자열을 보낸다. 아이콘은 업로드 확인이 필요해 여기서 바꾸지
/// 않고 `PATCH /teams/{teamId}/icon` 으로 바꾼다.
@Freezed(fromJson: false, toJson: true)
abstract class UpdateTeamRequest with _$UpdateTeamRequest {
  @JsonSerializable(includeIfNull: false, createFactory: false)
  const factory UpdateTeamRequest({String? name, String? description}) =
      _UpdateTeamRequest;
}
