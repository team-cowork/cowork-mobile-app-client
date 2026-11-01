import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../../shared/utils/initial.dart';
import '../../auth/data/auth_repository.dart';
import '../../channel/data/repositories/channel_repository.dart';
import '../../channel/domain/channel.dart';
import '../../channel/domain/enums/channel_type.dart';
import '../../profile/data/model/responses/user_response.dart';
import '../../team/data/repositories/team_repository.dart';
import '../domain/note.dart';
import 'meeting_note_request.dart';
import 'meeting_note_response.dart';

/// channel 서비스의 회의록(`/channels/{channelId}/meeting-notes`) 저장소.
///
/// 서버 회의록은 채널에 속하는데 회의록 탭 목록은 채널을 고르지 않는다. 그래서
/// 조회는 내 팀의 모든 채널을 훑어 한 목록으로 합친다. 작성은 새 노트 시트에서
/// 고른 회의록 채널에 쓴다.
///
/// ponytail: 채널이 많아지면 조회가 채널 수만큼 늘어나는 게 먼저 아플 자리다.
class NotesRepository {
  NotesRepository(
    AuthRepository auth, {
    required TeamRepository teams,
    required ChannelRepository channels,
  }) : this.withDio(
         createAuthedDio(ApiService.channel, auth),
         users: createAuthedDio(ApiService.user, auth),
         teams: teams,
         channels: channels,
       );

  NotesRepository.withDio(
    this._dio, {
    required Dio users,
    required TeamRepository teams,
    required ChannelRepository channels,
  }) : _users = users,
       _teams = teams,
       _channels = channels;

  final Dio _dio;

  /// 작성자 이름·사진(`/users/{id}`)을 읽는 user 서비스 dio.
  final Dio _users;

  final TeamRepository _teams;
  final ChannelRepository _channels;

  /// 내 팀의 회의록을 최신순으로 모아 온다.
  Future<List<Note>> fetchNotes() async {
    final ids = [
      for (final channel in await _myChannels())
        if (int.tryParse(channel.id) case final int id) id,
    ];

    // 목록에는 못 읽는 채널도 섞여 있다.
    final pages = (await Future.wait(ids.map(_notesOf))).nonNulls;
    final notes = pages.expand((page) => page.$2).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final authors = await _usersOf({for (final note in notes) note.createdBy});
    return [
      for (final note in notes)
        Note.fromMeetingNote(note, author: _authorOf(note, authors)),
    ];
  }

  /// 내 팀들의 회의록 채널. 새 노트·템플릿 화면이 채널을 고를 때 쓴다.
  ///
  /// 템플릿은 채널마다 따로 있으므로, 회의록을 쓰거나 템플릿을 고치려면 채널부터
  /// 정해야 한다.
  Future<List<Channel>> fetchNoteChannels() async => [
    for (final channel in await _myChannels())
      if (channel.type == ChannelType.meetingNote) channel,
  ];

  /// 편집 화면에서 처음 저장한 [note] 를 그 채널에 만든다.
  ///
  /// 서버가 정한 id 와 작성자를 채운 회의록을 돌려준다.
  Future<Note> createNote(Note note) async {
    final response = await _dio.post<String>(
      '/channels/${note.channelId}/meeting-notes',
      data: CreateMeetingNoteRequest(
        templateId: note.templateId,
        title: note.title,
        sections: note.sections,
      ).toJson(),
    );
    final created = MeetingNoteResponse.fromJson(
      unwrapPayload(response.data ?? ''),
    );
    final authors = await _usersOf({created.createdBy});
    return Note.fromMeetingNote(created, author: _authorOf(created, authors));
  }

  /// 편집한 회의록을 저장한다. 서버는 보낸 필드만 반영한다.
  Future<void> updateNote(Note note) => _dio.patch<String>(
    '/channels/${note.channelId}/meeting-notes/${note.id}',
    data: UpdateMeetingNoteRequest(
      title: note.title,
      sections: note.sections,
    ).toJson(),
  );

  /// 내 모든 팀의 채널. 팀 순서, 팀 안에서는 서버 순서다.
  Future<List<Channel>> _myChannels() async {
    final teams = await _teams.fetchMyTeams();
    final pages = await Future.wait([
      for (final team in teams) _channels.fetchChannels(team.id),
    ]);
    return pages.expand((page) => page).toList();
  }

  /// 채널 하나의 (id, 회의록). 못 읽는 채널(비공개 등)은 null 로 빠진다.
  ///
  /// 채널 하나가 403 이라고 목록 전체를 실패로 만들면 볼 수 있는 회의록까지 사라진다.
  /// 반대로 401·5xx·네트워크 장애까지 삼키면 장애가 `회의록 없음`으로 보이므로
  /// 403 만 건너뛰고 나머지는 그대로 던져 화면이 오류로 보여주게 둔다.
  Future<(int, List<MeetingNoteResponse>)?> _notesOf(int channelId) async {
    try {
      return (
        channelId,
        (await _list(
          '/channels/$channelId/meeting-notes',
        )).map(MeetingNoteResponse.fromJson).toList(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) return null;
      rethrow;
    }
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
        unwrapPayload((await _users.get<String>('/users/$id')).data ?? ''),
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
      initial: initialOf(name),
      avatarUrl: user?.profileImageUrl ?? '',
      date:
          '${date.month.toString().padLeft(2, '0')}.'
          '${date.day.toString().padLeft(2, '0')}',
    );
  }
}
