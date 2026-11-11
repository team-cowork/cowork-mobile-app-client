part of 'search_bloc.dart';

/// 검색 화면 상태.
///
/// 채널·사람·메시지는 서로 다른 서비스라 따로 실패할 수 있다. 하나가 실패해도 나머지는
/// 보이도록 섹션마다 [AsyncState] 를 따로 든다. 검색 전(빈 검색어)이면 셋 다
/// [AsyncInitial] 이다.
final class SearchState extends Equatable {
  const SearchState({
    this.query = '',
    this.recentSearches = const [],
    this.channels = const AsyncState.initial(),
    this.people = const AsyncState.initial(),
    this.messages = const AsyncState.initial(),
    this.loadingMoreMessages = false,
    this.moreMessagesFailed = false,
  });

  /// 지금 결과의 검색어. 앞뒤 공백은 뗀 값이다.
  final String query;

  /// 최근 것이 앞이다.
  final List<String> recentSearches;

  final AsyncState<List<SearchChannelResult>> channels;
  final AsyncState<List<SearchPersonResult>> people;

  /// 지금까지 받은 메시지 전부와 다음 페이지 커서.
  final AsyncState<SearchMessagePage> messages;

  /// 메시지 다음 페이지를 받는 중.
  final bool loadingMoreMessages;

  /// 메시지 다음 페이지를 받지 못했다. 다시 요청하면 지워진다.
  final bool moreMessagesFailed;

  SearchState copyWith({
    String? query,
    List<String>? recentSearches,
    AsyncState<List<SearchChannelResult>>? channels,
    AsyncState<List<SearchPersonResult>>? people,
    AsyncState<SearchMessagePage>? messages,
    bool? loadingMoreMessages,
    bool? moreMessagesFailed,
  }) => SearchState(
    query: query ?? this.query,
    recentSearches: recentSearches ?? this.recentSearches,
    channels: channels ?? this.channels,
    people: people ?? this.people,
    messages: messages ?? this.messages,
    loadingMoreMessages: loadingMoreMessages ?? this.loadingMoreMessages,
    moreMessagesFailed: moreMessagesFailed ?? this.moreMessagesFailed,
  );

  @override
  List<Object?> get props => [
    query,
    recentSearches,
    channels,
    people,
    messages,
    loadingMoreMessages,
    moreMessagesFailed,
  ];
}
