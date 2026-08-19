import 'package:dio/dio.dart';

import '../../../network/dio_client.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_response.dart';
import '../domain/note.dart';
import 'meeting_note_request.dart';
import 'meeting_note_response.dart';

/// 회의록(`/channels/{channelId}/meeting-notes`) 저장소.
///
/// 서버 회의록은 채널에 속하는데 앱에는 아직 채널을 고르는 화면이 없다. 그래서
/// 조회는 내 팀의 모든 채널을 훑어 한 목록으로 합치고, 작성은 그중 읽을 수 있는
/// 첫 채널에 쓴다.
///
/// ponytail: 채널 화면(#49)이 나오면 선택된 채널 하나만 읽고 쓰도록 좁힌다.
/// 채널이 많아지면 조회가 채널 수만큼 늘어나는 게 먼저 아플 자리다.
class NotesRepository {
  NotesRepository(AuthRepository auth) : this.withDio(createAuthedDio(auth));

  NotesRepository.withDio(this._dio);

  final Dio _dio;

  /// 마지막 조회에서 읽는 데 성공한 채널 id 들. 작성 대상 채널을 여기서 고른다.
  List<int> _channelIds = const [];

  /// 내 팀의 회의록을 최신순으로 모아 온다.
  Future<List<Note>> fetchNotes() async {
    final teams = await _list('/teams');
    final channels = await Future.wait([
      for (final team in teams) _list('/teams/${team['id']}/channels'),
    ]);
    final ids = [
      for (final channel in channels.expand((page) => page))
        if (channel['id'] case final int id) id,
    ];

    // 목록에는 못 읽는 채널도 섞여 있다. 읽힌 채널만 남겨야 작성도 거기로 간다.
    final pages = (await Future.wait(ids.map(_notesOf))).nonNulls.toList();
    _channelIds = [for (final (id, _) in pages) id];

    final notes = pages.expand((page) => page.$2).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final authors = await _usersOf({for (final note in notes) note.createdBy});
    return [
      for (final note in notes)
        Note.fromMeetingNote(note, author: _authorOf(note, authors)),
    ];
  }

  /// 새 회의록을 읽을 수 있는 첫 채널에 쓴다. 템플릿은 채널에서 켜져 있는 것을 쓴다.
  Future<void> createNote({
    required String title,
    required String summary,
  }) async {
    final channelId = _channelIds.firstOrNull;
    if (channelId == null) throw Exception('회의록을 쓸 채널이 없습니다.');

    await _dio.post<String>(
      '/channels/$channelId/meeting-notes',
      data: CreateMeetingNoteRequest(
        templateId: await _templateIdOf(channelId),
        title: title,
        sections: sectionsOf(summary: summary),
      ).toJson(),
    );
  }

  /// 편집한 회의록을 저장한다. 서버는 보낸 필드만 반영한다.
  Future<void> updateNote(Note note) => _dio.patch<String>(
    '/channels/${note.channelId}/meeting-notes/${note.id}',
    data: UpdateMeetingNoteRequest(
      title: note.title,
      sections: sectionsOf(
        summary: note.summary,
        agenda: note.agenda,
        decisions: note.decisions,
        actionItems: note.actionItems,
      ),
    ).toJson(),
  );

  /// 채널 하나의 (id, 회의록). 못 읽는 채널(비공개 등)은 null 로 빠진다.
  ///
  /// 채널 하나가 403 이라고 목록 전체를 실패로 만들면 볼 수 있는 회의록까지 사라진다.
  /// 반대로 401·5xx·네트워크 장애까지 삼키면 장애가 `회의록 없음`으로 보이므로
  /// 403 만 건너뛰고 나머지는 그대로 던져 화면이 오류로 보여주게 둔다.
  Future<(int, List<MeetingNoteResponse>)?> _notesOf(int channelId) async {
    try {
      return (
        channelId,
        (await _list('/channels/$channelId/meeting-notes'))
            .map(MeetingNoteResponse.fromJson)
            .toList(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) return null;
      rethrow;
    }
  }

  /// 켜져 있는 템플릿 id. 없으면 채널의 첫 템플릿을 쓴다.
  Future<int> _templateIdOf(int channelId) async {
    final templates = await _list('/channels/$channelId/meeting-note-templates');
    final template =
        templates.where((t) => t['isActive'] == true).firstOrNull ??
        templates.firstOrNull;
    if (template?['id'] case final int id) return id;
    throw Exception('채널에 회의록 템플릿이 없습니다.');
  }

  /// 작성자 id → 사용자. 회의록마다 부르지 않도록 중복을 없애 한 번씩만 읽는다.
  Future<Map<int, UserResponse>> _usersOf(Set<int> ids) async {
    final users = await Future.wait(
      ids.map((id) async => MapEntry(id, await _userOf(id))),
    );
    return {
      for (final user in users)
        if (user.value != null) user.key: user.value!,
    };
  }

  /// 사용자 한 명. 이름을 못 읽어도 회의록은 보여줘야 하므로 실패는 삼킨다.
  Future<UserResponse?> _userOf(int id) async {
    try {
      return UserResponse.fromJson(
        unwrapPayload((await _dio.get<String>('/users/$id')).data ?? ''),
      );
    } on DioException {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> _list(String path) async =>
      unwrapListPayload((await _dio.get<String>(path)).data ?? '');

  /// 카드 하단 `이름 · 날짜` 라인용 작성자.
  static NoteAuthor _authorOf(
    MeetingNoteResponse note,
    Map<int, UserResponse> users,
  ) {
    final user = users[note.createdBy];
    final name = user?.name ?? '';
    final date = note.createdAt;
    return NoteAuthor(
      authorId: note.createdBy,
      name: name.isEmpty ? '알 수 없음' : name,
      initial: name.isEmpty ? '?' : name.substring(0, 1),
      avatarUrl: user?.profileImageUrl ?? '',
      date:
          '${date.month.toString().padLeft(2, '0')}.'
          '${date.day.toString().padLeft(2, '0')}',
    );
  }
}
