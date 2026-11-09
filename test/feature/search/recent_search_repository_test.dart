import 'package:cowork_app/feature/search/data/repositories/recent_search_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  late SharedPreferencesAsync preferences;
  late RecentSearchRepository repository;

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
    preferences = SharedPreferencesAsync();
    repository = RecentSearchRepository(preferences);
  });

  test('팀마다 따로 저장하고 불러온다', () async {
    await repository.save(3, ['배포', '회고']);
    await repository.save(4, ['다른 팀']);

    expect(await repository.load(3), ['배포', '회고']);
    expect(await repository.load(4), ['다른 팀']);
    expect(await repository.load(5), isEmpty);
  });

  test('전부 지우면 모든 팀의 최근 검색어만 지우고 다른 값은 남긴다', () async {
    await repository.save(3, ['배포']);
    await repository.save(4, ['회고']);
    await preferences.setBool('notification.enabled', true);
    await preferences.setString('recent_searches', '접두어가 비슷한 다른 값');

    await repository.clearAll();

    expect(await repository.load(3), isEmpty);
    expect(await repository.load(4), isEmpty);
    expect(await preferences.getKeys(), {
      'notification.enabled',
      'recent_searches',
    });
  });

  test('지울 최근 검색어가 없어도 다른 값은 지우지 않는다', () async {
    await preferences.setBool('notification.enabled', true);

    await repository.clearAll();

    expect(await preferences.getBool('notification.enabled'), isTrue);
  });
}
