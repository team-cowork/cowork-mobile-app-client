import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/logger.dart';
import '../../../data/repositories/issue_repository.dart';
import '../../../domain/issue_target.dart';

part 'new_issue_event.dart';
part 'new_issue_state.dart';

/// 새 이슈 시트의 입력 상태를 관리하는 Bloc.
///
/// 목록([IssuesBloc])과 수명이 달라 별도 Bloc으로 둔다. 시트가 닫히면 함께 버려진다.
/// 저장소의 라벨 목록은 열 때 읽는다. 못 읽어도 라벨 없이 이슈를 만들 수 있다.
class NewIssueBloc extends Bloc<NewIssueEvent, NewIssueForm> {
  NewIssueBloc(this._repository, this._target) : super(const NewIssueForm()) {
    on<NewIssueTitleChanged>(
      (event, emit) => emit(state.copyWith(title: event.title)),
    );
    on<NewIssueBodyChanged>(
      (event, emit) => emit(state.copyWith(body: event.body)),
    );
    on<NewIssueLabelToggled>((event, emit) {
      final cleared = state.label == event.name;
      emit(
        state.copyWith(label: cleared ? null : event.name, clearLabel: cleared),
      );
    });
    on<NewIssueLabelsRequested>(_onLabels);
  }

  final IssueRepository _repository;
  final IssueTarget _target;

  Future<void> _onLabels(
    NewIssueLabelsRequested event,
    Emitter<NewIssueForm> emit,
  ) async {
    try {
      final labels = await _repository.fetchLabels(_target);
      emit(
        state.copyWith(
          labels: [
            for (final label in labels)
              // 진행중은 상태를 뜻하는 라벨이라 고르지 않는다. 만든 이슈는 계획됨이다.
              if (label.name != '진행중') label.name,
          ],
        ),
      );
    } catch (e, s) {
      Logger.e('이슈 라벨 조회 실패', tag: 'Issues', error: e, stackTrace: s);
    }
  }
}
