import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../network/http_error_message.dart';
import 'async_state.dart';
import 'logger.dart';

/// 서버 요청 하나(생성·저장 등)를 실행하고 그 진행 상태를 [AsyncState] 로 들고 있는 Bloc.
///
/// Flutter 공식 아키텍처의 Command 패턴을 flutter_bloc 으로 옮겼다.
/// (https://docs.flutter.dev/app-architecture/design-patterns/command)
/// 화면마다 반복하던 `중복 실행 막기 → loading → success / failure` 흐름을 한곳에
/// 두고, 화면은 실행할 액션만 넘긴다.
///
/// - [A]: 액션 인자 (예: 생성 요청 본문)
/// - [T]: 성공 결과 (예: 서버가 만든 채널)
///
/// 공식 문서와 달리 액션은 `Result<T>` 대신 예외를 던진다. 저장소들이 모두 예외로
/// 실패를 알리기 때문이다.
class CommandBloc<A, T> extends Bloc<CommandEvent<A>, AsyncState<T>> {
  CommandBloc(this._action, {String tag = 'Command'})
    : _tag = tag,
      super(AsyncInitial<T>()) {
    on<CommandRun<A>>(_onRun);
  }

  final Future<T> Function(A argument) _action;

  /// 실패 로그에 붙일 태그.
  final String _tag;

  Future<void> _onRun(CommandRun<A> event, Emitter<AsyncState<T>> emit) async {
    // 버튼은 실행 중에 잠기지만, 잠기기 전 프레임의 연타까지 여기서 막는다.
    if (state is AsyncLoading) return;
    // const 로 만들면 타입 변수를 못 써 AsyncLoading<Never> 가 된다.
    emit(AsyncLoading<T>());
    try {
      emit(AsyncState.success(await _action(event.argument)));
    } catch (e, s) {
      Logger.e('요청 실패', tag: _tag, error: e, stackTrace: s);
      emit(AsyncState.failure(e is DioException ? dioErrorMessage(e) : null));
    }
  }
}

sealed class CommandEvent<A> extends Equatable {
  const CommandEvent();

  /// [argument] 로 액션을 실행한다.
  const factory CommandEvent.run(A argument) = CommandRun<A>;

  @override
  List<Object?> get props => [];
}

final class CommandRun<A> extends CommandEvent<A> {
  const CommandRun(this.argument);

  final A argument;

  @override
  List<Object?> get props => [argument];
}
