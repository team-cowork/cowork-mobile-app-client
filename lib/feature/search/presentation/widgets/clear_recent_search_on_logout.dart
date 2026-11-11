import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/logger.dart';
import '../../../auth/presentation/blocs/auth/auth_bloc.dart';
import '../../data/repositories/recent_search_repository.dart';

/// 로그아웃 상태가 되면 기기에 남은 최근 검색어를 지운다.
///
/// 최근 검색어는 사용자 구분 없이 기기에 남으므로, 다음 사람이 보지 않게 지운다.
/// 로그아웃·세션 만료뿐 아니라 앱이 꺼진 동안 세션이 끝나 시작하자마자 로그아웃
/// 상태가 되는 경우(unknown → unauthenticated)도 포함한다. 앱 맨 위에 두어야
/// 어느 화면에 있든 듣는다.
class ClearRecentSearchOnLogout extends BlocListener<AuthBloc, AuthState> {
  const ClearRecentSearchOnLogout({super.key, super.child})
    : super(listenWhen: _becameUnauthenticated, listener: _clear);

  static bool _becameUnauthenticated(AuthState previous, AuthState current) =>
      current is Unauthenticated && previous is! Unauthenticated;

  static void _clear(BuildContext context, AuthState _) {
    context.read<RecentSearchRepository>().clearAll().catchError((
      Object e,
      StackTrace s,
    ) {
      Logger.e('최근 검색어 삭제 실패', tag: 'Search', error: e, stackTrace: s);
    });
  }
}
