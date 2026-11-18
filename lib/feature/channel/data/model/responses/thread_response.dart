import 'package:freezed_annotation/freezed_annotation.dart';

part 'thread_response.freezed.dart';
part 'thread_response.g.dart';

/// 채널의 스레드 하나. 부모 메시지에 이름과 보관 여부를 붙인 것이다. 답글은 메시지
/// API 로 읽는다.
@freezed
abstract class ThreadResponse with _$ThreadResponse {
  const factory ThreadResponse({
    required int id,
    required int channelId,
    @Default('') String name,

    /// 스레드의 부모(맨 위) 메시지 id.
    required String parentMessageId,
    @Default(false) bool isArchived,
  }) = _ThreadResponse;

  factory ThreadResponse.fromJson(Map<String, dynamic> json) =>
      _$ThreadResponseFromJson(json);
}
