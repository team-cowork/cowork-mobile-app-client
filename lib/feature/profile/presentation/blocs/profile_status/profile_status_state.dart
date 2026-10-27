part of 'profile_status_bloc.dart';

/// 상태 설정 시트의 저장 진행 상태.
final class ProfileStatusState extends Equatable {
  const ProfileStatusState({
    this.saving = false,
    this.saved = false,
    this.error,
  });

  /// 저장 요청을 보내고 기다리는 중인지. 중복 저장을 막는다.
  final bool saving;

  /// 저장이 끝났는지. 시트는 이걸 받고 닫힌다.
  final bool saved;

  /// 저장 실패 사유. 시트 안에 보여 준다.
  final String? error;

  @override
  List<Object?> get props => [saving, saved, error];
}
