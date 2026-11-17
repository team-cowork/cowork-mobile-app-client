part of 'invite_people_bloc.dart';

sealed class InvitePeopleEvent extends Equatable {
  const InvitePeopleEvent();

  /// 화면을 열었다. 이미 멤버인 사람을 알아 둔다.
  const factory InvitePeopleEvent.started() = InvitePeopleStarted;

  /// [query] 로 사람을 찾는다. 비어 있으면 결과를 비운다.
  const factory InvitePeopleEvent.searched(String query) = InvitePeopleSearched;

  /// [person] 을 고르거나 고른 목록에서 뺀다.
  const factory InvitePeopleEvent.toggled(SearchPersonResult person) =
      InvitePersonToggled;

  /// 고른 사람을 초대한다.
  const factory InvitePeopleEvent.submitted() = InvitePeopleSubmitted;

  @override
  List<Object?> get props => [];
}

final class InvitePeopleStarted extends InvitePeopleEvent {
  const InvitePeopleStarted();
}

final class InvitePeopleSearched extends InvitePeopleEvent {
  const InvitePeopleSearched(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class InvitePersonToggled extends InvitePeopleEvent {
  const InvitePersonToggled(this.person);

  final SearchPersonResult person;

  @override
  List<Object?> get props => [person];
}

final class InvitePeopleSubmitted extends InvitePeopleEvent {
  const InvitePeopleSubmitted();
}
