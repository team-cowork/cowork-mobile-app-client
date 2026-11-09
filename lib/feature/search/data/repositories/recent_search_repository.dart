import 'package:shared_preferences/shared_preferences.dart';

/// 팀별 최근 검색어. 서버 API 가 없어 기기에 저장한다.
///
/// 키는 팀 단위(`recent_search.{teamId}`)다. 사용자 id 를 키에 넣으려면 검색 화면마다
/// `/users/me` 를 불러야 해서, 대신 로그아웃하면 [clearAll] 로 전부 지운다. 같은
/// 기기에서 다른 계정으로 들어와도 앞 사람의 검색어가 보이지 않는다.
///
/// 검색어는 민감한 값이 아니라 암호화 저장소(flutter_secure_storage)가 아닌
/// shared_preferences 에 둔다.
class RecentSearchRepository {
  RecentSearchRepository([SharedPreferencesAsync? preferences])
    : _preferences = preferences ?? SharedPreferencesAsync();

  final SharedPreferencesAsync _preferences;

  /// 보여 줄 최대 개수. 넘치면 오래된 것부터 버린다.
  static const maxTerms = 10;

  static const _keyPrefix = 'recent_search.';

  static String _keyOf(int teamId) => '$_keyPrefix$teamId';

  /// [teamId] 팀의 최근 검색어. 최근 것이 앞이다.
  Future<List<String>> load(int teamId) async =>
      await _preferences.getStringList(_keyOf(teamId)) ?? const [];

  /// [teamId] 팀의 최근 검색어를 [terms] 로 덮어쓴다.
  Future<void> save(int teamId, List<String> terms) =>
      _preferences.setStringList(_keyOf(teamId), terms);

  /// 모든 팀의 최근 검색어를 지운다. 다른 기능이 저장한 값은 건드리지 않는다.
  Future<void> clearAll() async {
    final keys = await _preferences.getKeys();
    // allowList 는 null 이면 전부 지운다. 빈 집합은 지금 플랫폼 구현들에선 아무것도
    // 지우지 않지만, 그 동작에 기대지 않도록 지울 키가 없으면 부르지 않는다.
    if (!keys.any((key) => key.startsWith(_keyPrefix))) return;
    await _preferences.clear(
      allowList: {
        for (final key in keys)
          if (key.startsWith(_keyPrefix)) key,
      },
    );
  }

  /// [terms] 맨 앞에 [term] 을 둔 새 목록. 이미 있으면 앞으로 옮기고
  /// [maxTerms] 를 넘으면 오래된 것을 버린다.
  static List<String> withTerm(List<String> terms, String term) =>
      [term, ...terms.where((t) => t != term)].take(maxTerms).toList();
}
