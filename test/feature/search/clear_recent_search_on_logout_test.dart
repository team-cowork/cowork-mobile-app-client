import 'dart:async';

import 'package:cowork_app/feature/auth/data/auth_repository.dart';
import 'package:cowork_app/feature/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:cowork_app/feature/search/data/repositories/recent_search_repository.dart';
import 'package:cowork_app/feature/search/presentation/widgets/clear_recent_search_on_logout.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// 앱 시작 때 세션 복원 결과는 [restored] 로 정하고, 만료 알림은 테스트가 보낸다.
class _FakeAuthRepository extends Fake implements AuthRepository {
  _FakeAuthRepository({required this.restored});

  final bool restored;
  final expired = StreamController<void>.broadcast();

  @override
  Stream<void> get sessionExpired => expired.stream;

  @override
  Future<bool> restoreSession() async => restored;
}

void main() {
  late RecentSearchRepository recent;

  setUp(() async {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    recent = RecentSearchRepository(SharedPreferencesAsync());
    await recent.save(3, ['앞 사람의 검색어']);
  });

  Future<void> pumpApp(WidgetTester tester, AuthRepository auth) async {
    await tester.pumpWidget(
      RepositoryProvider.value(
        value: recent,
        child: BlocProvider(
          create: (_) =>
              AuthBloc(repository: auth)
                ..add(const AuthEvent.sessionRestored()),
          child: const ClearRecentSearchOnLogout(child: SizedBox()),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('앱을 켰을 때 세션이 끝나 있으면 최근 검색어를 지운다', (tester) async {
    await pumpApp(tester, _FakeAuthRepository(restored: false));

    expect(await recent.load(3), isEmpty);
  });

  testWidgets('로그인한 채 세션이 만료되면 최근 검색어를 지운다', (tester) async {
    final auth = _FakeAuthRepository(restored: true);
    await pumpApp(tester, auth);
    expect(await recent.load(3), ['앞 사람의 검색어']);

    auth.expired.add(null);
    await tester.pumpAndSettle();

    expect(await recent.load(3), isEmpty);
  });

  testWidgets('세션이 복원되면 최근 검색어를 남긴다', (tester) async {
    await pumpApp(tester, _FakeAuthRepository(restored: true));

    expect(await recent.load(3), ['앞 사람의 검색어']);
  });
}
