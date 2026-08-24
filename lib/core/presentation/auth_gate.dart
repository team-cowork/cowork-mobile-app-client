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
      listenWhen: (_, state) =>
          state is Unauthenticated && state.message != null,
      listener: (context, state) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text((state as Unauthenticated).message!)),
      ),
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
