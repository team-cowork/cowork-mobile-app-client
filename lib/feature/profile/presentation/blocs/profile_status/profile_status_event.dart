part of 'profile_status_bloc.dart';

sealed class ProfileStatusEvent extends Equatable {
  const ProfileStatusEvent();

  @override
  List<Object?> get props => [];
}

/// 고른 상태와 상태 메시지 저장을 요청한다.
final class ProfileStatusSubmitted extends ProfileStatusEvent {
  const ProfileStatusSubmitted({
    required this.customStatus,
    required this.message,
  });

  /// 서버에 보낼 상태 값 (예: `DO_NOT_DISTURB`).
  final String customStatus;

  /// 상태 메시지. 비어 있으면 서버 값을 지운다.
  final String message;

  @override
  List<Object?> get props => [customStatus, message];
}
