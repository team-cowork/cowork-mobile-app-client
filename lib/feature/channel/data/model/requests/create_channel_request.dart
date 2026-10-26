import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/enums/channel_type.dart';
import '../channel_view_type.dart';

part 'create_channel_request.freezed.dart';
part 'create_channel_request.g.dart';

/// `POST /channels` 요청 본문.
///
/// 필드는 서버 본문 그대로다. 앱의 [ChannelType] 하나가 서버 `type`·`viewType`
/// 두 값이 되므로, 화면에서는 [CreateChannelRequest.of] 로 만든다.
@Freezed(fromJson: false, toJson: true)
abstract class CreateChannelRequest with _$CreateChannelRequest {
  const factory CreateChannelRequest({
    required int teamId,
    required String name,

    /// 서버 채널 종류. 음성만 VOICE, 나머지는 TEXT.
    required String type,

    /// 화면 종류. (예: TEXT, WEBHOOK, MEETING_NOTE)
    required String viewType,
    required bool isPrivate,
  }) = _CreateChannelRequest;

  /// 앱 채널 유형 [type] 을 서버 `type`/`viewType` 짝으로 바꿔 담는다.
  factory CreateChannelRequest.of({
    required int teamId,
    required String name,
    required ChannelType type,
    required bool isPrivate,
  }) => CreateChannelRequest(
    teamId: teamId,
    name: name,
    type: serverTypeOf(type),
    viewType: viewTypeOf(type),
    isPrivate: isPrivate,
  );
}
