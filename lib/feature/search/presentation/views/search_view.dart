import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../domain/search_result.dart';
import '../viewModels/search_bloc.dart';
import '../widgets/search_channel_result_tile.dart';
import '../widgets/search_header.dart';
import '../widgets/search_person_result_tile.dart';
import '../widgets/search_recent_terms.dart';
import '../widgets/search_section_label.dart';

/// 검색 화면.
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
  late final TextEditingController _controller = TextEditingController(
    text: widget.overview.query,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchHeader(
            controller: _controller,
            onBack: () => Navigator.of(context).maybePop(),
            onClear: () => setState(_controller.clear),
            onSubmitted: (query) =>
                context.read<SearchBloc>().add(const SearchRequested()),
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
                  SearchRecentTerms(
                    terms: widget.overview.recentSearches,
                    onTapTerm: (term) => setState(() {
                      _controller.text = term;
                    }),
                  ),
                  if (widget.overview.channels.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.s10,
                      children: [
                        const SearchSectionLabel(label: '채널'),
                        for (final channel in widget.overview.channels)
                          SearchChannelResultTile(result: channel),
                      ],
                    ),
                  if (widget.overview.people.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: AppSpacing.s10,
                      children: [
                        const SearchSectionLabel(label: '사람'),
                        for (final person in widget.overview.people)
                          SearchPersonResultTile(result: person),
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
