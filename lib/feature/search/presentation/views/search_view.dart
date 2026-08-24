import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../domain/enums/avatar_color.dart';
import '../../domain/search_result.dart';
import '../blocs/search/search_bloc.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<SearchBloc, SearchOverview>(
      create: (_) => SearchBloc()..add(const SearchRequested()),
      errorTitle: '검색 결과를 불러오지 못했어요',
      onRetry: (context) =>
          context.read<SearchBloc>().add(const SearchRequested()),
      builder: (context, overview) => _SearchBody(overview: overview),
    );
  }
}

class _SearchBody extends StatefulWidget {
  const _SearchBody({required this.overview});

  final SearchOverview overview;

  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search(String query) {
    context.read<SearchBloc>().add(SearchRequested(query: query));
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
            onClear: () => setState(() {
              _controller.clear();
              _search('');
            }),
            onSubmitted: _search,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.s16,
                AppSpacing.s6,
                AppSpacing.s16,
                AppSpacing.s16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: AppSpacing.s20,
                children: [
                  _SearchRecentTerms(
                    terms: widget.overview.recentSearches,
                    onTapTerm: (term) {
                      setState(() => _controller.text = term);
                      _search(term);
                    },
                  ),
                  if (widget.overview.channels.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.s10,
                      children: [
                        const _SearchSectionLabel(label: '채널'),
                        for (final channel in widget.overview.channels)
                          _SearchChannelResultTile(result: channel),
                      ],
                    ),
                  if (widget.overview.people.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.s10,
                      children: [
                        const _SearchSectionLabel(label: '사람'),
                        for (final person in widget.overview.people)
                          _SearchPersonResultTile(result: person),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
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
                  const Icon(
                    AppIcon.search,
                    size: 18,
                    color: AppColors.neutral300,
                  ),
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

/// "채널", "사람" 같은 검색 결과 섹션 라벨.
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
  const _SearchChannelResultTile({
    required this.result,
    // ignore: unused_element_parameter -- 결과 탭 이동 미연결. 배선되면 이 줄을 지운다.
    this.onTap,
  });

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
