import 'package:go_router/go_router.dart';

import '../feature/channel/presentation/views/channel_settings_view.dart';
import '../feature/channel/presentation/views/members_view.dart';
import '../feature/chat/presentation/views/channel_view.dart';
import '../feature/chat/presentation/views/dm_list_view.dart';
import '../feature/chat/presentation/views/thread_view.dart';
import '../feature/issues/domain/issue.dart';
import '../feature/issues/presentation/views/issue_detail_view.dart';
import '../feature/notes/domain/note.dart';
import '../feature/notes/domain/note_draft.dart';
import '../feature/notes/domain/note_template.dart';
import '../feature/notes/presentation/views/note_detail_view.dart';
import '../feature/notes/presentation/views/note_edit_view.dart';
import '../feature/notes/presentation/views/note_template_edit_view.dart';
import '../feature/notes/presentation/views/note_templates_view.dart';
import '../feature/notifications/presentation/views/notifications_view.dart';
import '../feature/profile/presentation/views/edit_profile_view.dart';
import '../feature/search/presentation/views/search_view.dart';
import '../feature/setting/presentation/views/settings_view.dart';
import 'auth_gate.dart';

/// 채널 대화와 그 하위 화면. 채널 id 를 경로에 담아 딥링크·앱 복원으로 들어와도
/// 화면을 다시 만들 수 있다. id 가 숫자가 아니면 홈으로 보낸다.
final channelRoute = GoRoute(
  path: '/chat/channel/:channelId',
  redirect: (context, state) => _channelIdOf(state) == null ? '/' : null,
  // 검색 결과에서 오면 `messageId` 쿼리로 보여 줄 메시지를 받는다.
  builder: (context, state) => ChannelView(
    channelId: _channelIdOf(state)!,
    focusMessageId: state.uri.queryParameters['messageId'],
  ),
  routes: [
    // 스레드는 부모 메시지 id 를 쿼리로 받는다. 없으면 채널로 돌려보낸다.
    GoRoute(
      path: 'thread',
      redirect: (context, state) => _parentMessageIdOf(state) == null
          ? '/chat/channel/${_channelIdOf(state)}'
          : null,
      builder: (context, state) => ThreadView(
        channelId: _channelIdOf(state)!,
        parentMessageId: _parentMessageIdOf(state)!,
      ),
    ),
    GoRoute(path: 'members', builder: (context, state) => const MembersView()),
    GoRoute(
      path: 'settings',
      builder: (context, state) =>
          ChannelSettingsView(channelId: _channelIdOf(state)!),
    ),
  ],
);

int? _channelIdOf(GoRouterState state) =>
    int.tryParse(state.pathParameters['channelId'] ?? '');

String? _parentMessageIdOf(GoRouterState state) {
  final id = state.uri.queryParameters['parentMessageId'];
  return id == null || id.isEmpty ? null : id;
}

int? _teamIdOf(GoRouterState state) =>
    int.tryParse(state.uri.queryParameters['teamId'] ?? '');

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
    // 검색은 팀 안으로 범위가 묶여 팀 id 를 쿼리로 받는다. 없으면 홈으로 보낸다.
    GoRoute(
      path: '/search',
      redirect: (context, state) => _teamIdOf(state) == null ? '/' : null,
      builder: (context, state) => SearchView(teamId: _teamIdOf(state)!),
    ),
    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsView(),
    ),
    GoRoute(
      path: '/notes/detail',
      builder: (context, state) => NoteDetailView(note: state.extra! as Note),
    ),
    GoRoute(
      path: '/notes/edit',
      builder: (context, state) => NoteEditView(note: state.extra! as Note),
    ),
    // 새 노트 시트에서 고른 값으로 아직 서버에 없는 회의록을 쓴다.
    GoRoute(
      path: '/notes/new',
      builder: (context, state) =>
          NoteEditView.create(draft: state.extra! as NoteDraft),
    ),
    // extra 는 처음 고를 회의록 채널 id. 회의록 탭에서 열면 없다.
    GoRoute(
      path: '/notes/templates',
      builder: (context, state) =>
          NoteTemplatesView(channelId: state.extra as int?),
    ),
    GoRoute(
      path: '/notes/templates/edit',
      builder: (context, state) =>
          NoteTemplateEditView(template: state.extra! as NoteTemplate),
    ),
    GoRoute(
      path: '/profile/edit',
      builder: (context, state) => const EditProfileView(),
    ),
    GoRoute(
      path: '/profile/settings',
      builder: (context, state) => const SettingsView(),
    ),
    channelRoute,
    GoRoute(
      path: '/issues/detail',
      builder: (context, state) =>
          IssueDetailView(issue: state.extra! as Issue),
    ),
    GoRoute(path: '/dm', builder: (context, state) => const DmListView()),
  ],
);
