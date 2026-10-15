import '../domain/channel.dart';
import 'channel_view_type.dart';

/// `/channels` 계열 응답의 채널 하나.
///
/// 목록 조회와 생성이 같은 표현을 돌려주므로 응답 모델은 하나다. 화면에서 쓰는
/// 필드만 옮긴다.
class ChannelResponse {
  const ChannelResponse({required this.id, required this.name, this.viewType});

  factory ChannelResponse.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! int) throw const FormatException('채널 응답에 id 가 없습니다.');
    return ChannelResponse(
      id: id,
      name: json['name'] as String? ?? '',
      viewType: json['viewType'] as String?,
    );
  }

  final int id;
  final String name;

  /// 화면 종류. (예: TEXT, WEBHOOK, MEETING_NOTE)
  final String? viewType;

  Channel toChannel() =>
      Channel(id: '$id', name: name, type: channelTypeOf(viewType));
}
