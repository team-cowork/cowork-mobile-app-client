import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/bloc_scaffold.dart';
import '../../domain/search_result.dart';
import '../blocs/search/search_bloc.dart';
import '../widgets/search_body.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocScaffold<SearchBloc, SearchOverview>(
      create: (_) => SearchBloc()..add(const SearchRequested()),
      errorTitle: '검색 결과를 불러오지 못했어요',
      onRetry: (context) =>
          context.read<SearchBloc>().add(const SearchRequested()),
      builder: (context, overview) => SearchBody(overview: overview),
    );
  }
}
