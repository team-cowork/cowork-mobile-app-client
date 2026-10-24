import 'package:cowork_app/core/presentation/main_shell.dart';
import 'package:cowork_app/core/utils/base_scaffold.dart';
import 'package:cowork_app/feature/auth/presentation/blocs/auth/auth_bloc.dart';
import 'package:cowork_app/feature/auth/presentation/views/login_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// 인증 상태에 따라 로그인 화면과 메인 셸을 가른다.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, state) =>
          state is Unauthenticated &&
          (previous is Authenticated || state.message != null),
      listener: (context, state) {
        // 로그아웃·세션 만료 때 이 화면 위에 쌓인 채팅·설정 화면과 바텀시트를 걷어야
        // 로그인 화면이 보인다. `go('/')` 는 시트처럼 page 가 아닌 route 를 남긴다.
        Navigator.of(context).popUntil((route) => route.isFirst);
        final message = (state as Unauthenticated).message;
        if (message != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) => switch (state) {
        Authenticated() => const MainShell(),
        AuthUnknown() => const BaseScaffold(
          body: Center(child: CoworkLoadingPane()),
        ),
        // 인증 중에는 브라우저가 앞에 떠 있다. 콜백 사이 재탭만 막는다.
        _ => LoginView(
          onDataGsmLogin: state is AuthInProgress
              ? null
              : () => context.read<AuthBloc>().add(
                  const AuthEvent.signInRequested(),
                ),
        ),
      },
    );
  }
}
