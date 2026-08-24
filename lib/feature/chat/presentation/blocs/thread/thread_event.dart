part of 'thread_bloc.dart';

sealed class ThreadEvent extends Equatable {
  const ThreadEvent();

  const factory ThreadEvent.requested() = ThreadRequested;

  @override
  List<Object?> get props => [];
}

final class ThreadRequested extends ThreadEvent {
  const ThreadRequested();
}
