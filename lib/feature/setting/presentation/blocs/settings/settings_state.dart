part of 'settings_bloc.dart';

/// 설정 화면 상태. 성공 시 [SettingsData]를 담는다.
typedef SettingsState = AsyncState<SettingsData>;

/// 불러온 설정과 토글 저장 진행 상황.
///
/// 저장 실패는 화면 전체를 에러로 바꾸지 않고 토글만 되돌린 뒤 사유를 알린다.
/// 그래서 실패 사유를 [AsyncFailure] 가 아니라 성공 데이터 안에 싣는다.
final class SettingsData extends Equatable {
  const SettingsData(this.settings, {this.saving = false, this.saveError});

  final Settings settings;

  /// 토글 저장 중. 끝나기 전에 다른 토글을 받으면 요청 순서가 꼬이므로 막는다.
  final bool saving;

  /// 직전 저장이 실패한 사유. 화면이 한 번 보여 준다.
  final String? saveError;

  @override
  List<Object?> get props => [settings, saving, saveError];
}
