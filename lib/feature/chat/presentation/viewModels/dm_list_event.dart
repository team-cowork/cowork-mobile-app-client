part of 'dm_list_bloc.dart';

sealed class DmListEvent extends Equatable {
  const DmListEvent();

  const factory DmListEvent.requested() = DmListRequested;

  @override
  List<Object?> get props => [];
}

final class DmListRequested extends DmListEvent {
  const DmListRequested();
}
