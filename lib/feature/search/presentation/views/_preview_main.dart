import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/auth_repository.dart';
import '../../data/repositories/recent_search_repository.dart';
import '../../data/repositories/search_repository.dart';
import 'search_view.dart';

/// 화면 배치만 보는 미리보기. 로그인하지 않아 검색 요청은 실패 섹션으로 보인다.
void main() {
  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => SearchRepository(AuthRepository())),
        RepositoryProvider(create: (_) => RecentSearchRepository()),
      ],
      child: const MaterialApp(home: SearchView(teamId: 1)),
    ),
  );
}
