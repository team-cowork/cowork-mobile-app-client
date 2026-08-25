import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/issue.dart';
import '../viewModels/issue_comments_cubit.dart';
import '../widgets/issue_detail_body.dart';

class IssueDetailView extends StatelessWidget {
  const IssueDetailView({required this.issue, super.key});

  final Issue issue;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => IssueCommentsCubit(issue.number),
      child: IssueDetailBody(issue: issue),
    );
  }
}
