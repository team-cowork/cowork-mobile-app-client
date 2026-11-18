import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/issue_repository.dart';
import '../../domain/issue_detail_args.dart';
import '../blocs/issue_comments/issue_comments_cubit.dart';
import '../widgets/issue_detail_body.dart';

class IssueDetailView extends StatelessWidget {
  const IssueDetailView({required this.args, super.key});

  final IssueDetailArgs args;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IssueCommentsCubit(
        context.read<IssueRepository>(),
        args.target,
        args.issue.number,
      )..load(),
      child: IssueDetailBody(issue: args.issue),
    );
  }
}
