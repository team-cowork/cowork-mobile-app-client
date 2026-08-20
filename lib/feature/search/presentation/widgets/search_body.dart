import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/search_result.dart';
import '../viewModels/search_bloc.dart';
import 'search_channel_result_tile.dart';
import 'search_header.dart';
import 'search_person_result_tile.dart';
import 'search_recent_terms.dart';
import 'search_section_label.dart';

class SearchBody extends StatefulWidget {
  const SearchBody({super.key, required this.overview});

  final SearchOverview overview;

  @override
  State<SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<SearchBody> {
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
          SearchHeader(
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
                  SearchRecentTerms(
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
