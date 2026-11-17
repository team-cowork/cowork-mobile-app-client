import 'package:equatable/equatable.dart';

/// 이슈를 읽고 쓰는 대상. 프로젝트에 연결된 GitHub 저장소 하나다.
class IssueTarget extends Equatable {
  const IssueTarget({
    required this.projectId,
    required this.repoId,
    required this.label,
  });

  final int projectId;
  final int repoId;

  /// 헤더에 보일 이름. `프로젝트 · 저장소`.
  final String label;

  @override
  List<Object?> get props => [projectId, repoId, label];
}
