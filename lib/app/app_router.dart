import 'package:go_router/go_router.dart';

import '../feature/channel/presentation/views/channel_settings_view.dart';
import '../feature/channel/presentation/views/members_view.dart';
import '../feature/chat/presentation/views/channel_view.dart';
import '../feature/chat/presentation/views/dm_list_view.dart';
import '../feature/chat/presentation/views/thread_view.dart';
import '../feature/issues/domain/issue.dart';
import '../feature/issues/presentation/views/issue_detail_view.dart';
import '../feature/notes/domain/note.dart';
import '../feature/notes/presentation/views/note_detail_view.dart';
import '../feature/notes/presentation/views/note_edit_view.dart';
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
  builder: (context, state) => ChannelView(channelId: _channelIdOf(state)!),
  routes: [
    GoRoute(path: 'thread', builder: (context, state) => const ThreadView()),
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

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthGate()),
    GoRoute(path: '/search', builder: (context, state) => const SearchView()),
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
