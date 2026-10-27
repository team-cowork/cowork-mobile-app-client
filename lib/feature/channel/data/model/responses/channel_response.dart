import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../domain/channel.dart';
import '../channel_view_type.dart';

part 'channel_response.freezed.dart';
part 'channel_response.g.dart';

/// `/channels` 계열 응답의 채널 하나.
///
/// 목록 조회와 생성이 같은 표현을 돌려주므로 응답 모델은 하나다. 화면에서 쓰는
/// 필드만 옮긴다.
@freezed
abstract class ChannelResponse with _$ChannelResponse {
  const ChannelResponse._();

  const factory ChannelResponse({
    /// 없으면 fromJson 이 던진다.
    required int id,
    @Default('') String name,

    /// 화면 종류. (예: TEXT, WEBHOOK, MEETING_NOTE)
    String? viewType,

    /// 채널 설명. 채널 화면 머리에 보인다.
    String? description,
  }) = _ChannelResponse;

  factory ChannelResponse.fromJson(Map<String, dynamic> json) =>
      _$ChannelResponseFromJson(json);

  Channel toChannel() =>
      Channel(id: '$id', name: name, type: channelTypeOf(viewType));
}
