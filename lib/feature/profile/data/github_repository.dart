import 'package:dio/dio.dart';

import '../../../core/utils/logger.dart';

/// GitHub 공개 이벤트로 커밋 스트릭을 만든다.
///
/// 잔디(contributions) 그래프는 공식 REST API 가 없고 GraphQL 은 토큰을 요구하는데,
/// 앱에 심을 토큰이 없다. 그래서 인증 없이 열려 있는 공개 이벤트를 센다.
/// 한계는 GitHub 쪽 제약이다. 최근 90일 · 이벤트 300개까지만 남고, 비공개 저장소
/// 커밋은 잡히지 않는다. 그래서 히트맵은 "커밋 기록"이지 잔디와 같은 값이 아니다.
///
/// ponytail: 백엔드가 스트릭 API 를 주면 이 파일과 호출부를 통째로 지운다.
class GithubRepository {
  GithubRepository([Dio? dio])
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://api.github.com',
              headers: const {'Accept': 'application/vnd.github+json'},
            ),
          );

  final Dio _dio;

  /// [githubId] 의 날짜별 커밋 수. 날짜는 기기 시간대의 자정으로 맞춘다.
  ///
  /// 실패하면 빈 맵을 준다. 스트릭은 프로필의 곁가지라 여기서 던지면 이름·사진까지
  /// 같이 못 뜬다. 아이디를 잘못 적어 404 가 나는 것도 정상 경로다.
  Future<Map<DateTime, int>> commitsByDay(String githubId) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/users/$githubId/events/public',
        queryParameters: const {'per_page': 100},
      );

      final counts = <DateTime, int>{};
      for (final event in response.data ?? const []) {
        if (event is! Map || event['type'] != 'PushEvent') continue;
        final at = DateTime.tryParse(event['created_at'] as String? ?? '');
        if (at == null) continue;
        final local = at.toLocal();
        final day = DateTime(local.year, local.month, local.day);
        // size 는 그 push 에 담긴 커밋 수. 없으면 push 하나를 커밋 하나로 본다.
        final size = (event['payload'] as Map?)?['size'];
        counts[day] = (counts[day] ?? 0) + (size is int ? size : 1);
      }
      return counts;
    } catch (e, s) {
      Logger.e('GitHub 스트릭 조회 실패', tag: 'Profile', error: e, stackTrace: s);
      return const {};
    }
  }
}
