part of 'members_bloc.dart';

sealed class MembersEvent extends Equatable {
  const MembersEvent();

  const factory MembersEvent.requested() = MembersRequested;

  @override
  List<Object?> get props => [];
}

final class MembersRequested extends MembersEvent {
  const MembersRequested();
}
