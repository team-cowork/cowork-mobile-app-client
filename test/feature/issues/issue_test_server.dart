import 'dart:convert';
import 'dart:typed_data';

import 'package:cowork_app/feature/issues/data/repositories/issue_repository.dart';
import 'package:dio/dio.dart';

/// 이슈 테스트용 가짜 project 서비스. 프로젝트 1(저장소 7)에 이슈 둘과 댓글을 두고,
/// 받은 요청을 `METHOD 경로` 로 적어 둔다. 모르는 경로는 404 로 답한다.
class FakeIssueServer implements HttpClientAdapter {
  /// 내가 참여한 프로젝트. 서버가 주는 쪽수 응답(`content`)에 담긴다.
  List<Map<String, dynamic>> projects = [
    {'id': 1, 'name': '개발'},
  ];

  /// 프로젝트 id → 연결된 저장소.
  Map<int, List<Map<String, dynamic>>> repos = {
    1: [
      {'id': 7, 'githubRepoUrl': 'https://github.com/org/backend'},
    ],
  };

  List<Map<String, dynamic>> issues = [
    issueJson(14, '음성 채널 인원 제한', labels: ['기능']),
    issueJson(9, '재연결 리뷰 반영', labels: ['버그', '진행중']),
  ];

  List<Map<String, dynamic>> comments = [
    {
      'id': 1,
      'author': 'octocat',
      'body': '확인했습니다.',
      'htmlUrl': '',
      'createdAt': '2026-10-23T05:00:00Z',
    },
  ];

  final labels = [
    {'name': '기능', 'color': '0e8a16'},
    {'name': '진행중', 'color': 'fbca04'},
    {'name': '버그', 'color': 'd73a4a'},
  ];

  final calls = <String>[];
  final bodies = <String, Map<String, dynamic>>{};

  /// 이 요청에는 500 을 돌려준다.
  String? failing;

  /// 이슈·댓글을 만들면 서버가 비동기로 목록에 넣는 것을 흉내 낸다.
  void Function(Map<String, dynamic> body)? onCreateIssue;
  void Function(Map<String, dynamic> body)? onCreateComment;

  static const _repo = '/project/projects/1/github-repos/7/issues';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final uri = options.uri;
    final path = uri.path.replaceFirst('/api', '');
    final call = '${options.method} $path';
    calls.add(call);
    Map<String, dynamic> body = const {};
    if (requestStream != null) {
      final bytes = (await requestStream.toList()).expand((c) => c).toList();
      if (bytes.isNotEmpty) {
        body = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
        bodies[call] = body;
      }
    }
    if (call == failing) return _json({'message': '서버 오류'}, 500);

    if (call == 'POST $_repo') {
      onCreateIssue?.call(body);
      return _json({'status': 'OK', 'code': 202, 'message': 'OK'}, 202);
    }
    if (call == 'POST $_repo/14/comments') {
      onCreateComment?.call(body);
      return _json({'status': 'OK', 'code': 202, 'message': 'OK'}, 202);
    }
    return switch (call) {
      'GET /project/projects/me' => _ok({'content': projects}),
      'GET /project/projects/1/github-repos' => _ok(repos[1] ?? []),
      'GET /project/projects/2/github-repos' => _ok(repos[2] ?? []),
      'GET $_repo' => _ok(issues),
      'GET $_repo/labels' => _ok(labels),
      'GET $_repo/14/comments' => _ok(comments),
      _ => _json({'message': '없는 경로: $path'}, 404),
    };
  }

  static ResponseBody _ok(Object data) =>
      _json({'status': 'OK', 'code': 200, 'message': 'OK', 'data': data});

  static ResponseBody _json(Object body, [int status = 200]) =>
      ResponseBody.fromString(
        jsonEncode(body),
        status,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}

/// 서버 이슈 응답 하나.
Map<String, dynamic> issueJson(
  int number,
  String title, {
  List<String> labels = const [],
  String author = 'octocat',
}) => {
  'number': number,
  'title': title,
  'author': author,
  'state': 'open',
  'htmlUrl': 'https://github.com/org/backend/issues/$number',
  'labels': labels,
  'createdAt': '2026-10-23T05:00:00Z',
  'updatedAt': '2026-10-23T05:00:00Z',
};

IssueRepository issueRepositoryOf(FakeIssueServer server) =>
    IssueRepository.withDio(
      Dio(
        BaseOptions(
          baseUrl: 'https://example.test/api/project',
          contentType: Headers.jsonContentType,
          responseType: ResponseType.plain,
        ),
      )..httpClientAdapter = server,
    );
