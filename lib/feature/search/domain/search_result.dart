import 'package:equatable/equatable.dart';

import 'enums/avatar_color.dart';

/// 검색 결과에 뜨는 채널 하나.
class SearchChannelResult extends Equatable {
  const SearchChannelResult({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;

  /// 채널명 (예: 백엔드).
  final String name;

  /// 채널 안에서 검색어와 매칭된 미리보기 텍스트.
  final String description;

  @override
  List<Object?> get props => [id, name, description];
}

/// 검색 결과에 뜨는 사람 하나.
class SearchPersonResult extends Equatable {
  const SearchPersonResult({
    required this.id,
    required this.name,
    required this.role,
    required this.initial,
    required this.avatarColor,
  });

  final String id;

  /// 표시 이름 (예: 도윤).
  final String name;

  /// 직무/역할 (예: 백엔드 개발자).
  final String role;

  /// 아바타 이미지가 없을 때 표시할 한 글자.
  final String initial;

  final AvatarColor avatarColor;

  @override
  List<Object?> get props => [id, name, role, initial, avatarColor];
}

/// 검색 화면 전체 데이터.
class SearchOverview extends Equatable {
  const SearchOverview({
    required this.query,
    required this.recentSearches,
    required this.channels,
    required this.people,
  });

  /// 검색창에 표시할 초기 검색어.
  final String query;

  /// 최근 검색어 목록.
  final List<String> recentSearches;

  final List<SearchChannelResult> channels;
  final List<SearchPersonResult> people;

  @override
  List<Object?> get props => [query, recentSearches, channels, people];
}
