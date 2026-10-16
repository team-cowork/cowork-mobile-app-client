import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_status_request.freezed.dart';
part 'update_status_request.g.dart';

/// `PATCH /users/me/status` 요청 본문.
///
/// [status] 는 필수라, 상태 메시지만 바꿀 때도 서버가 들고 있던 값을 그대로
/// 되돌려 보낸다. [message] 는 null 이면 상태 메시지를 지운다. 그래서 null 도
/// 빼지 않고 보낸다.
@Freezed(fromJson: false, toJson: true)
abstract class UpdateStatusRequest with _$UpdateStatusRequest {
  const factory UpdateStatusRequest({required String status, String? message}) =
      _UpdateStatusRequest;
}
