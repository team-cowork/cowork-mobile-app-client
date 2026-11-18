import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_icon_response.freezed.dart';
part 'team_icon_response.g.dart';

/// `POST /teams/icon/confirm`, `PATCH /teams/{teamId}/icon` 응답.
@freezed
abstract class TeamIconResponse with _$TeamIconResponse {
  const factory TeamIconResponse({
    /// 업로드를 마친 아이콘의 CDN URL.
    required String iconUrl,
  }) = _TeamIconResponse;

  factory TeamIconResponse.fromJson(Map<String, dynamic> json) =>
      _$TeamIconResponseFromJson(json);
}
