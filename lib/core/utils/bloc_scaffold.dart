import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'async_state.dart';
import 'base_scaffold.dart';

/// [AsyncState]를 쓰는 Bloc 화면의 공통 셸.
///
/// [BaseScaffold] 위에 Bloc 생성과 로딩/실패 분기까지 얹어, 화면은 성공 상태의
/// 본문([builder])만 그리면 된다. 로딩·실패 화면은 앱 전역에서 동일하게 처리한다.
///
/// [appBar]는 [BlocProvider] 하위에 배치되므로, 그 안에서 `Builder`로
/// `context.read<B>()`를 호출할 수 있다.
class BlocScaffold<B extends BlocBase<AsyncState<T>>, T>
    extends StatelessWidget {
  const BlocScaffold({
    super.key,
    required this.create,
    required this.errorTitle,
    required this.onRetry,
    required this.builder,
    this.appBar,
    this.bottomNavigationBar,
  });

  /// 화면 진입 시 Bloc을 만들고 최초 로드 이벤트를 넣는다.
  final B Function(BuildContext context) create;

  /// 실패 화면에 보여줄 제목. (예: `'회의록을 불러오지 못했어요'`)
  final String errorTitle;

  /// 실패 화면의 `다시 시도`를 눌렀을 때. `context`에서 [B]를 읽을 수 있다.
  final void Function(BuildContext context) onRetry;

  /// 성공 상태의 본문.
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
        body: BlocBuilder<B, AsyncState<T>>(
          builder: (context, state) => switch (state) {
            AsyncFailure<T>() => Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.s16),
                child: CoworkErrorState(
                  title: errorTitle,
                  description: '잠시 후 다시 시도해 주세요.',
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
