import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'async_state.dart';
import 'base_scaffold.dart';

/// 여러 화면이 [Bloc] 하나를 공유할 때 쓰는 [BlocScaffold] 변형.
///
/// [BlocScaffold]는 Bloc의 상태가 그대로 `AsyncState<T>`여야 하지만, 이 위젯은
/// [selector]로 상태 안의 한 구획만 골라 로딩/실패/성공을 분기한다.
/// (예: `GroupChatBloc`처럼 채널·스레드·멤버·설정을 한 Bloc이 같이 들고 있을 때.)
class BlocSectionScaffold<B extends BlocBase<S>, S, T>
    extends StatelessWidget {
  const BlocSectionScaffold({
    super.key,
    required this.create,
    required this.selector,
    required this.errorTitle,
    required this.onRetry,
    required this.builder,
    this.appBar,
    this.bottomNavigationBar,
  });

  final B Function(BuildContext context) create;

  /// Bloc의 전체 상태에서 이 화면이 보여줄 [AsyncState] 구획을 고른다.
  final AsyncState<T> Function(S state) selector;

  final String errorTitle;
  final void Function(BuildContext context) onRetry;
  final Widget Function(BuildContext context, T data) builder;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<B>(
      create: create,
      child: BaseScaffold(
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        body: BlocBuilder<B, S>(
          builder: (context, state) => switch (selector(state)) {
            AsyncFailure<T>(:final message) => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: CoworkErrorState(
                  title: errorTitle,
                  description: message ?? '잠시 후 다시 시도해 주세요.',
                  retryLabel: '다시 시도',
                  onRetry: () => onRetry(context),
                ),
              ),
            ),
            AsyncSuccess<T>(:final data) => builder(context, data),
            _ => const Center(child: CoworkLoadingPane()),
          },
        ),
      ),
    );
  }
}
