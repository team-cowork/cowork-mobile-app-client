part of 'personal_chat_bloc.dart';

sealed class PersonalChatEvent extends Equatable {
  const PersonalChatEvent();

  const factory PersonalChatEvent.requested() = PersonalChatRequested;

  @override
  List<Object?> get props => [];
}

final class PersonalChatRequested extends PersonalChatEvent {
  const PersonalChatRequested();
}
