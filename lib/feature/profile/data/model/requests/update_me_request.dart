import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_me_request.freezed.dart';
part 'update_me_request.g.dart';

/// `PATCH /users/me` 요청 본문.
///
/// 서버는 보낸 필드만 반영한다. 지금 편집 화면이 다루는 세 가지만 담고,
/// `github_id`/`roles` 는 편집 수단이 생길 때 필드를 늘린다.
@Freezed(fromJson: false, toJson: true)
abstract class UpdateMeRequest with _$UpdateMeRequest {
  const factory UpdateMeRequest({
    required String name,
    required String nickname,

    /// 자기소개.
    required String description,
  }) = _UpdateMeRequest;
}
