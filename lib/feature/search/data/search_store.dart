import '../domain/enums/avatar_color.dart';
import '../domain/search_result.dart';

class SearchStore {
  SearchStore._();

  static final SearchStore instance = SearchStore._();

  static const _recentSearches = ['재연결 로직', '웹훅 보안', '스프린트 회고'];

  static const _channels = [
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
  ];

  static const _people = [
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
  ];

  SearchOverview search(String query) {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return const SearchOverview(
        query: '',
        recentSearches: _recentSearches,
        channels: _channels,
        people: _people,
      );
    }

    final lower = trimmed.toLowerCase();
    return SearchOverview(
      query: trimmed,
      recentSearches: _recentSearches,
      channels: _channels
          .where(
            (channel) =>
                channel.name.toLowerCase().contains(lower) ||
                channel.description.toLowerCase().contains(lower),
          )
          .toList(),
      people: _people
          .where(
            (person) =>
                person.name.toLowerCase().contains(lower) ||
                person.role.toLowerCase().contains(lower),
          )
          .toList(),
    );
  }
}
