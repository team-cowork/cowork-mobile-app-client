import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../shared/widgets/base_scaffold.dart';
import '../../data/repositories/recent_search_repository.dart';
import '../../data/repositories/search_repository.dart';
import '../../domain/enums/avatar_color.dart';
import '../../domain/search_result.dart';
import '../blocs/search/search_bloc.dart';

/// [teamId] 팀 안의 채널·사람·메시지를 찾는 화면.
class SearchView extends StatelessWidget {
  const SearchView({required this.teamId, super.key});

  final int teamId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SearchBloc(
        context.read<SearchRepository>(),
        context.read<RecentSearchRepository>(),
        teamId: teamId,
      )..add(const SearchStarted()),
      child: const BaseScaffold(body: _SearchBody()),
    );
  }
}

/// 검색창과 결과.
///
/// 검색창은 [BlocBuilder] 밖에 둔다. 안에 두면 결과가 로딩으로 바뀔 때마다 검색창이
/// 새로 만들어져 입력 중인 글자가 지워진다.
class _SearchBody extends StatefulWidget {
  const _SearchBody();

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final TextEditingController _controller = TextEditingController();
  final _scroll = ScrollController();

  /// 목록 끝에서 이만큼 남으면 메시지 다음 페이지를 받는다.
  static const _loadMoreExtent = 200.0;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _search(String query) {
    context.read<SearchBloc>().add(SearchRequested(query));
  }

  void _loadMoreMessages() {
    context.read<SearchBloc>().add(const SearchMoreMessagesRequested());
  }

  /// 끝 근처까지 내리면 다음 페이지를 받는다.
  bool _onScroll(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      _loadMoreNearEnd(notification.metrics);
    }
    return false;
  }

  /// 메시지 결과가 바뀌면 그려진 뒤 끝이 가까운지 본다. 결과가 화면을 못 채우면
  /// 스크롤할 수 없어 [_onScroll] 이 불리지 않기 때문이다.
  void _onMessagesChanged(BuildContext context, SearchState state) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _loadMoreNearEnd(_scroll.position);
    });
  }

  /// 받기에 실패했으면 스크롤마다 다시 보내지 않고 `다시 시도` 를 누를 때만 보낸다.
  /// 받는 중이거나 마지막 페이지면 Bloc 이 무시한다.
  void _loadMoreNearEnd(ScrollMetrics metrics) {
    if (metrics.extentAfter < _loadMoreExtent &&
        !context.read<SearchBloc>().state.moreMessagesFailed) {
      _loadMoreMessages();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SearchHeader(
            controller: _controller,
            onBack: () => Navigator.of(context).maybePop(),
            onClear: () {
              _controller.clear();
              _search('');
            },
            onSubmitted: _search,
          ),
          Expanded(
            child: BlocListener<SearchBloc, SearchState>(
              listenWhen: (previous, current) =>
                  previous.messages != current.messages,
              listener: _onMessagesChanged,
              child: NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) => SingleChildScrollView(
                    controller: _scroll,
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.s16,
                      AppSpacing.s6,
                      AppSpacing.s16,
                      AppSpacing.s16,
                    ),
                    child: _SearchResults(
                      state: state,
                      onTapTerm: (term) {
                        _controller.text = term;
                        _search(term);
                      },
                      onRetry: () => _search(state.query),
                      onRetryMoreMessages: _loadMoreMessages,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 최근 검색어와 섹션별 결과. 섹션은 따로 로딩·실패한다.
class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.state,
    required this.onTapTerm,
    required this.onRetry,
    required this.onRetryMoreMessages,
  });

  final SearchState state;
  final ValueChanged<String> onTapTerm;
  final VoidCallback onRetry;
  final VoidCallback onRetryMoreMessages;

  @override
  Widget build(BuildContext context) {
    final channels = state.channels;
    final people = state.people;
    final messages = state.messages;
    final nothingFound =
        channels is AsyncSuccess<List<SearchChannelResult>> &&
        channels.data.isEmpty &&
        people is AsyncSuccess<List<SearchPersonResult>> &&
        people.data.isEmpty &&
        messages is AsyncSuccess<SearchMessagePage> &&
        messages.data.messages.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s20,
      children: [
        if (state.recentSearches.isNotEmpty)
          _SearchRecentTerms(terms: state.recentSearches, onTapTerm: onTapTerm),
        if (nothingFound)
          const CoworkEmptyState(
            icon: Icons.search_off_rounded,
            title: '검색 결과가 없어요',
            description: '다른 검색어로 찾아보세요.',
          ),
        if (_shows(channels, (data) => data.isEmpty))
          _SearchSection(
            label: '채널',
            state: channels,
            onRetry: onRetry,
            itemsOf: (data) => [
              for (final channel in data)
                _SearchChannelResultTile(
                  result: channel,
                  onTap: () => context.push('/chat/channel/${channel.id}'),
                ),
            ],
          ),
        if (_shows(people, (data) => data.isEmpty))
          _SearchSection(
            label: '사람',
            state: people,
            onRetry: onRetry,
            itemsOf: (data) => [
              for (final person in data)
                _SearchPersonResultTile(result: person),
            ],
          ),
        if (_shows(messages, (data) => data.messages.isEmpty))
          _SearchSection(
            label: '메시지',
            state: messages,
            onRetry: onRetry,
            itemsOf: (data) => [
              for (final message in data.messages)
                _SearchMessageResultTile(
                  result: message,
                  onTap: () => context.push(
                    '/chat/channel/${message.channelId}?messageId=${message.id}',
                  ),
                ),
              if (state.loadingMoreMessages)
                const Center(
                  child: SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              else if (state.moreMessagesFailed)
                Center(
                  child: CoworkButton(
                    label: '메시지를 더 불러오지 못했어요 · 다시 시도',
                    variant: CoworkButtonVariant.weak,
                    color: CoworkButtonColor.neutral,
                    onPressed: onRetryMoreMessages,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  /// 검색 전이거나 결과가 비었으면 섹션을 숨긴다. 로딩·실패는 보인다.
  static bool _shows<T>(AsyncState<T> state, bool Function(T data) isEmpty) =>
      switch (state) {
        AsyncInitial<T>() => false,
        AsyncSuccess<T>(:final data) => !isEmpty(data),
        AsyncLoading<T>() || AsyncFailure<T>() => true,
      };
}

/// 라벨 + 섹션 결과. 로딩이면 스피너, 실패면 재시도 카드를 그 섹션 자리에 둔다.
class _SearchSection<T> extends StatelessWidget {
  const _SearchSection({
    required this.label,
    required this.state,
    required this.onRetry,
    required this.itemsOf,
  });

  final String label;
  final AsyncState<T> state;
  final VoidCallback onRetry;
  final List<Widget> Function(T data) itemsOf;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s10,
      children: [
        _SearchSectionLabel(label: label),
        ...switch (state) {
          AsyncSuccess<T>(:final data) => itemsOf(data),
          AsyncFailure<T>(:final message) => [
            CoworkErrorState(
              title: '$label 검색에 실패했어요',
              description: message ?? '잠시 후 다시 시도해 주세요.',
              retryLabel: '다시 시도',
              onRetry: onRetry,
            ),
          ],
          AsyncInitial<T>() ||
          AsyncLoading<T>() => const [CoworkLoadingPane(height: 96)],
        },
      ],
    );
  }
}

/// 검색 화면 상단의 뒤로가기 + 검색창.
class _SearchHeader extends StatelessWidget {
  const _SearchHeader({
    required this.controller,
    this.onBack,
    this.onClear,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final VoidCallback? onBack;
  final VoidCallback? onClear;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s12,
        AppSpacing.s4,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      child: Row(
        spacing: AppSpacing.s10,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onBack,
            child: const SizedBox(
              width: 32,
              height: 44,
              child: Icon(
                AppIcon.back,
                size: 20,
                color: AppColors.darkOnSurface,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s12),
              decoration: BoxDecoration(
                color: AppColors.neutral800,
                border: Border.all(color: AppColors.neutral700),
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              child: Row(
                spacing: AppSpacing.s8,
                children: [
                  AppIcon.search(size: 18),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      onSubmitted: onSubmitted,
                      style: AppFont.subtextL.copyWith(
                        color: AppColors.darkOnSurface,
                      ),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  _ClearButton(onPressed: onClear),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClearButton extends StatelessWidget {
  const _ClearButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 18,
        height: 18,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: AppColors.neutral700,
          shape: BoxShape.circle,
        ),
        child: AppIcon.clear(size: 12),
      ),
    );
  }
}

/// "최근 검색" 섹션. 최근 검색어를 칩으로 나열한다.
class _SearchRecentTerms extends StatelessWidget {
  const _SearchRecentTerms({required this.terms, this.onTapTerm});

  final List<String> terms;
  final ValueChanged<String>? onTapTerm;

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: AppSpacing.s10,
      children: [
        Text(
          '최근 검색',
          style: AppFont.itemCount.copyWith(color: AppColors.neutral300),
        ),
        Wrap(
          spacing: AppSpacing.s8,
          runSpacing: AppSpacing.s8,
          children: [
            for (final term in terms)
              _RecentTermChip(term: term, onTap: () => onTapTerm?.call(term)),
          ],
        ),
      ],
    );
  }
}

class _RecentTermChip extends StatelessWidget {
  const _RecentTermChip({required this.term, this.onTap});

  final String term;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.s12,
          vertical: AppSpacing.s6,
        ),
        decoration: BoxDecoration(
          color: AppColors.neutral750,
          border: Border.all(color: AppColors.neutral700),
          borderRadius: BorderRadius.circular(AppRadius.r14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSpacing.s6,
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 13,
              color: AppColors.neutral300,
            ),
            Text(
              term,
              style: AppFont.subtextM.copyWith(color: AppColors.darkOnSurface),
            ),
          ],
        ),
      ),
    );
  }
}

/// "채널", "사람", "메시지" 같은 검색 결과 섹션 라벨.
class _SearchSectionLabel extends StatelessWidget {
  const _SearchSectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppFont.itemCount.copyWith(
        color: AppColors.neutral300,
        letterSpacing: 0.4,
      ),
    );
  }
}

/// 검색 결과의 채널 한 행. 해시 아이콘 + 채널명 + 미리보기 텍스트.
class _SearchChannelResultTile extends StatelessWidget {
  const _SearchChannelResultTile({required this.result, this.onTap});

  final SearchChannelResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Row(
          spacing: AppSpacing.s12,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.neutral700,
                borderRadius: BorderRadius.circular(AppRadius.r10),
              ),
              child: AppIcon.hashChannel(),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    result.name,
                    style: AppFont.labelS.copyWith(
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  Text(
                    result.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.subtextS.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 검색 결과의 사람 한 행. 아바타 + 이름 + 역할.
class _SearchPersonResultTile extends StatelessWidget {
  const _SearchPersonResultTile({
    required this.result,
    // ignore: unused_element_parameter -- 결과 탭 이동 미연결. 배선되면 이 줄을 지운다.
    this.onTap,
  });

  final SearchPersonResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Row(
          spacing: AppSpacing.s12,
          children: [
            CoworkAvatar(
              initials: result.initial,
              size: 36,
              backgroundColor: _colorFor(result.avatarColor),
              foregroundColor: AppColors.white,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    result.name,
                    style: AppFont.labelS.copyWith(
                      color: AppColors.darkOnSurface,
                    ),
                  ),
                  Text(
                    result.role,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppFont.subtextS.copyWith(
                      color: AppColors.neutral300,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Color _colorFor(AvatarColor color) => switch (color) {
    AvatarColor.green => AppColors.green500,
    AvatarColor.amber => AppColors.amber500,
    AvatarColor.blue => AppColors.blue500,
    AvatarColor.red => AppColors.red500,
  };
}

/// 검색 결과의 메시지 한 행. 검색어가 굵게 보이는 본문 조각 + 보낸 날짜.
class _SearchMessageResultTile extends StatelessWidget {
  const _SearchMessageResultTile({required this.result, this.onTap});

  final SearchMessageResult result;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final base = AppFont.subtextM.copyWith(color: AppColors.darkOnSurface);
    final createdAt = result.createdAt.toLocal();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.s8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 2,
          children: [
            Text.rich(
              TextSpan(
                children: highlightSpansOf(
                  result.highlights.firstOrNull ?? result.content,
                  base: base,
                  highlight: base.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${createdAt.month}월 ${createdAt.day}일',
              style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
            ),
          ],
        ),
      ),
    );
  }
}

/// 서버가 `<em>키워드</em>` 로 감싼 조각을 [highlight] 스타일 구간으로 나눈다.
/// 짝이 맞지 않는 태그는 글자 그대로 둔다.
@visibleForTesting
List<TextSpan> highlightSpansOf(
  String snippet, {
  required TextStyle base,
  required TextStyle highlight,
}) {
  final spans = <TextSpan>[];
  var start = 0;
  for (final match in _emTag.allMatches(snippet)) {
    if (match.start > start) {
      spans.add(
        TextSpan(text: snippet.substring(start, match.start), style: base),
      );
    }
    spans.add(TextSpan(text: match.group(1), style: highlight));
    start = match.end;
  }
  if (start < snippet.length) {
    spans.add(TextSpan(text: snippet.substring(start), style: base));
  }
  return spans;
}

final _emTag = RegExp('<em>(.*?)</em>', dotAll: true);
