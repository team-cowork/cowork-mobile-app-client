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

/// 검색 결과에 뜨는 메시지 하나.
class SearchMessageResult extends Equatable {
  const SearchMessageResult({
    required this.id,
    required this.channelId,
    required this.authorId,
    required this.content,
    required this.highlights,
    required this.createdAt,
  });

  final String id;

  /// 메시지가 있는 채널. 결과를 누르면 이 채널로 간다.
  final int channelId;

  /// 시스템·웹훅 메시지면 null.
  final int? authorId;

  /// 메시지 본문 전체.
  final String content;

  /// 검색어를 `<em>키워드</em>` 로 감싼 본문 조각. 서버가 못 만들면 빈 목록이다.
  final List<String> highlights;

  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    channelId,
    authorId,
    content,
    highlights,
    createdAt,
  ];
}

/// 메시지 검색 한 페이지. 최신순이다.
class SearchMessagePage extends Equatable {
  const SearchMessagePage({required this.messages, required this.nextCursor});

  final List<SearchMessageResult> messages;

  /// 다음 페이지를 받을 커서. 마지막 페이지면 null.
  final String? nextCursor;

  bool get hasMore => nextCursor != null;

  @override
  List<Object?> get props => [messages, nextCursor];
}
