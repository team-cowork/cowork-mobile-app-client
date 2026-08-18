import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/core/utils/bloc_scaffold.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

/// 상태를 테스트에서 직접 밀어 넣기 위한 최소 Cubit.
class _FakeCubit extends Cubit<AsyncState<String>> {
  _FakeCubit() : super(const AsyncState.initial());

  void push(AsyncState<String> next) => emit(next);
}

void main() {
  late _FakeCubit cubit;

  Widget subject() => MaterialApp(
    home: BlocScaffold<_FakeCubit, String>(
      create: (_) => cubit,
      errorTitle: '불러오지 못했어요',
      onRetry: (_) => cubit.push(const AsyncState.success('재시도')),
      builder: (_, data) => Text(data),
    ),
  );

  setUp(() => cubit = _FakeCubit());

  testWidgets('initial/loading 상태는 로딩 화면을 보여준다', (tester) async {
    await tester.pumpWidget(subject());
    expect(find.byType(CoworkLoadingPane), findsOneWidget);

    cubit.push(const AsyncState.loading());
    await tester.pump();
    expect(find.byType(CoworkLoadingPane), findsOneWidget);
  });

  testWidgets('success 상태는 builder 본문을 보여준다', (tester) async {
    await tester.pumpWidget(subject());
    cubit.push(const AsyncState.success('본문'));
    await tester.pump();

    expect(find.text('본문'), findsOneWidget);
    expect(find.byType(CoworkLoadingPane), findsNothing);
  });

  testWidgets('failure 상태는 에러 화면을 보여주고 다시 시도가 동작한다', (tester) async {
    await tester.pumpWidget(subject());
    cubit.push(const AsyncState.failure());
    await tester.pump();
    expect(find.text('불러오지 못했어요'), findsOneWidget);

    await tester.tap(find.text('다시 시도'));
    await tester.pump();
    expect(find.text('재시도'), findsOneWidget);
  });
}
