part of 'channel_message_bloc.dart';

/// 채널 대화 화면 상태. 성공 시 [ChannelConversation] 을 담는다.
typedef ChannelMessageState = AsyncState<ChannelConversation>;

/// 불러온 채널 대화.
///
/// 이전 메시지 불러오기·전송 실패는 화면 전체를 에러로 바꾸지 않고 [errorMessage] 로
/// 한 번 알린다.
final class ChannelConversation extends Equatable {
  const ChannelConversation({
    required this.name,
    required this.description,
    required this.messages,
    this.hasOlder = false,
    this.loadingOlder = false,
    this.hasNewer = false,
    this.loadingNewer = false,
    this.focusMessageId,
    this.errorMessage,
    this.closedReason,
  });

  final String name;
  final String description;

  /// 오래된 것부터 최신 순.
  final List<ChatMessage> messages;

  /// 서버에 더 이전 메시지가 남아 있다.
  final bool hasOlder;

  /// 이전 메시지를 불러오는 중.
  final bool loadingOlder;

  /// 서버에 더 최근 메시지가 남아 있다. 과거 위치(검색 결과)에서 열었을 때만 true.
  final bool hasNewer;

  /// 이후 메시지를 불러오는 중.
  final bool loadingNewer;

  /// 화면이 맞춰 보여 줄 메시지(검색 결과에서 고른 것). 최근 대화로 옮기면 null.
  final String? focusMessageId;

  /// 직전 이전 메시지 불러오기·전송이 실패한 사유. 화면이 한 번 보여 준다.
  final String? errorMessage;

  /// 채널이 지워졌거나 더 볼 수 없게 된 사유. 있으면 화면이 알리고 채널을 닫는다.
  final String? closedReason;

  ChannelConversation withError(String message) => ChannelConversation(
    name: name,
    description: description,
    messages: messages,
    hasOlder: hasOlder,
    loadingOlder: loadingOlder,
    hasNewer: hasNewer,
    loadingNewer: loadingNewer,
    focusMessageId: focusMessageId,
    errorMessage: message,
    closedReason: closedReason,
  );

  @override
  List<Object?> get props => [
    name,
    description,
    messages,
    hasOlder,
    loadingOlder,
    hasNewer,
    loadingNewer,
    focusMessageId,
    errorMessage,
    closedReason,
  ];
}
