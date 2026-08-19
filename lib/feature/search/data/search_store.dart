import '../domain/enums/avatar_color.dart';
import '../domain/search_result.dart';

/// 검색 화면의 목(mock) 데이터 저장소.
///
/// 백엔드 연동 전까지 정적 시드 데이터를 반환한다.
/// 실제 API 연동 시 이 싱글턴을 리포지토리로 교체한다.
class SearchStore {
  SearchStore._();

  static final SearchStore instance = SearchStore._();

  SearchOverview get overview => const SearchOverview(
    query: '재연결',
    recentSearches: ['재연결 로직', '웹훅 보안', '스프린트 회고'],
    channels: [
      SearchChannelResult(
        id: 'backend',
        name: '백엔드',
        description: 'PR #2 재연결 로직 리뷰 부탁드려요',
      ),
      SearchChannelResult(
        id: 'notice',
        name: '공지사항',
        description: '재연결 정책 업데이트 안내',
      ),
    ],
    people: [
      SearchPersonResult(
        id: 'doyoon',
        name: '도윤',
        role: '백엔드 개발자',
        initial: '도',
        avatarColor: AvatarColor.green,
      ),
      SearchPersonResult(
        id: 'seoyeon',
        name: '서연',
        role: '프론트엔드 개발자',
        initial: '서',
        avatarColor: AvatarColor.amber,
      ),
    ],
  );
}
