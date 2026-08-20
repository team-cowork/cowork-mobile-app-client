import 'package:go_router/go_router.dart';

import '../../feature/notes/domain/note.dart';
import '../../feature/notes/presentation/views/note_detail_view.dart';
import '../../feature/notes/presentation/views/note_edit_view.dart';
import '../../feature/notifications/presentation/views/notifications_view.dart';
import '../../feature/profile/presentation/views/edit_profile_view.dart';
import '../../feature/search/presentation/views/search_view.dart';
import '../../feature/settings/presentation/views/settings_view.dart';
import 'auth_gate.dart';

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
  ],
);
