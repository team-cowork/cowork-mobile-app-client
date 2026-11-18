part of 'invite_codes_bloc.dart';

sealed class InviteCodesEvent extends Equatable {
  const InviteCodesEvent();

  /// 초대 코드 목록을 (다시) 읽는다.
  const factory InviteCodesEvent.requested() = InviteCodesRequested;

  /// 화면이 코드를 새로 만들었다.
  const factory InviteCodesEvent.added(InviteResponse invite) = InviteCodeAdded;

  /// [inviteCode] 를 무효화한다.
  const factory InviteCodesEvent.revokeRequested(String inviteCode) =
      InviteCodeRevokeRequested;

  @override
  List<Object?> get props => [];
}

final class InviteCodesRequested extends InviteCodesEvent {
  const InviteCodesRequested();
}

final class InviteCodeAdded extends InviteCodesEvent {
  const InviteCodeAdded(this.invite);

  final InviteResponse invite;

  @override
  List<Object?> get props => [invite];
}

final class InviteCodeRevokeRequested extends InviteCodesEvent {
  const InviteCodeRevokeRequested(this.inviteCode);

  final String inviteCode;

  @override
  List<Object?> get props => [inviteCode];
}
