import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_status_request.freezed.dart';
part 'update_status_request.g.dart';

/// `PATCH /users/me/status` 요청 본문.
///
/// [customStatus] 는 서버가 필수로 받아, 상태 설정 시트에서 사용자가 고른 값을
/// 보낸다. [message] 는 null 이면 상태 메시지를 지운다. 그래서 null 도 빼지 않고
/// 보낸다.
///
/// 서버는 보낸 키만 바꾼다. `expiresAt` 은 앱에서 정할 수단이 없어 보내지 않고,
/// 그래서 웹에서 정해 둔 만료 시각도 그대로 남는다.
@Freezed(fromJson: false, toJson: true)
abstract class UpdateStatusRequest with _$UpdateStatusRequest {
  @JsonSerializable(fieldRename: FieldRename.snake, createFactory: false)
  const factory UpdateStatusRequest({
    /// 사용자가 고른 상태(예: `DO_NOT_DISTURB`). 접속 상태(`status`)와 별개다.
    required String customStatus,
    String? message,
  }) = _UpdateStatusRequest;
}
