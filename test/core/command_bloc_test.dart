import 'dart:async';

import 'package:cowork_app/core/utils/async_state.dart';
import 'package:cowork_app/core/utils/command_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  /// [bloc] 에 [event] 를 넣고, 처리가 끝날 때까지 나온 상태를 모은다.
  Future<List<AsyncState<String>>> statesOf(
    CommandBloc<int, String> bloc,
    List<CommandEvent<int>> events,
  ) async {
    final states = <AsyncState<String>>[];
    final sub = bloc.stream.listen(states.add);
    events.forEach(bloc.add);
    await pumpEventQueue();
    await sub.cancel();
    return states;
  }

  test('성공하면 loading → success(결과) 로 간다', () async {
    final bloc = CommandBloc<int, String>((n) async => '채널 $n');

    expect(await statesOf(bloc, [const CommandEvent.run(1)]), [
      const AsyncState<String>.loading(),
      const AsyncState<String>.success('채널 1'),
    ]);
  });

  test('서버가 거절하면 상태 코드와 서버 사유를 failure 에 담는다', () async {
    final request = RequestOptions(path: '/channels');
    final bloc = CommandBloc<int, String>(
      (_) async => throw DioException.badResponse(
        statusCode: 403,
        requestOptions: request,
        response: Response(
          requestOptions: request,
          statusCode: 403,
          data: '{"message":"팀 멤버만 접근할 수 있습니다."}',
        ),
      ),
    );

    expect(
      (await statesOf(bloc, [const CommandEvent.run(1)])).last,
      const AsyncState<String>.failure('(403) 팀 멤버만 접근할 수 있습니다.'),
    );
  });

  test('네트워크가 아닌 실패는 사유 없이 failure 로 둔다', () async {
    final bloc = CommandBloc<int, String>(
      (_) async => throw const FormatException('응답이 이상함'),
    );

    expect(
      (await statesOf(bloc, [const CommandEvent.run(1)])).last,
      const AsyncState<String>.failure(),
    );
  });

  test('실행 중에 다시 실행하면 무시한다', () async {
    final gate = Completer<void>();
    var calls = 0;
    final bloc = CommandBloc<int, String>((n) async {
      calls++;
      await gate.future;
      return '채널 $n';
    });

    bloc
      ..add(const CommandEvent.run(1))
      ..add(const CommandEvent.run(2));
    await pumpEventQueue();
    gate.complete();
    await pumpEventQueue();

    expect(calls, 1);
    expect(bloc.state, const AsyncState<String>.success('채널 1'));
  });

  test('실패한 뒤에는 다시 실행할 수 있다', () async {
    var fail = true;
    final bloc = CommandBloc<int, String>((n) async {
      if (fail) throw const FormatException('일시 오류');
      return '채널 $n';
    });

    await statesOf(bloc, [const CommandEvent.run(1)]);
    fail = false;
    await statesOf(bloc, [const CommandEvent.run(1)]);

    expect(bloc.state, const AsyncState<String>.success('채널 1'));
  });
}
