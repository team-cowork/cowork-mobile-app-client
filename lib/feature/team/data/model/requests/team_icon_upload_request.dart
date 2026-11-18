import 'package:freezed_annotation/freezed_annotation.dart';

part 'team_icon_upload_request.freezed.dart';
part 'team_icon_upload_request.g.dart';

/// `POST /teams/icon/presigned` 요청 본문.
///
/// [contentType] 은 presigned 서명에 들어가므로 실제 업로드 요청의 Content-Type 과
/// 같아야 한다. 서버는 `image/jpeg`, `image/png`, `image/webp` 만 받는다.
@Freezed(fromJson: false, toJson: true)
abstract class TeamIconUploadRequest with _$TeamIconUploadRequest {
  @JsonSerializable(createFactory: false)
  const factory TeamIconUploadRequest({required String contentType}) =
      _TeamIconUploadRequest;
}
