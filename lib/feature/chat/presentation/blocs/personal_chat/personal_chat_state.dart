part of 'personal_chat_bloc.dart';

typedef PersonalChatState = AsyncState<PersonalChatData>;

/// DM 목록 화면이 그리는 데이터. 대화 목록과, 화면이 한 번 알릴 숨기기 실패 사유를 든다.
final class PersonalChatData extends Equatable {
  const PersonalChatData({required this.conversations, this.errorMessage});

  /// 마지막 메시지가 최근인 대화가 앞이다.
  final List<DirectMessagePreview> conversations;

  /// 직전 숨기기가 실패한 사유. 화면이 한 번 보여 준다.
  final String? errorMessage;

  PersonalChatData withError(String message) =>
      PersonalChatData(conversations: conversations, errorMessage: message);

  @override
  List<Object?> get props => [conversations, errorMessage];
}
