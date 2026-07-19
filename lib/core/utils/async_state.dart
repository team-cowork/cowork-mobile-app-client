import 'package:equatable/equatable.dart';

/// 단일 데이터를 비동기로 불러오는 화면의 공통 Bloc 상태.
///
/// 화면마다 initial/loading/success/failure를 똑같이 선언하던 것을 하나로 모은다.
/// 로드 대상 타입만 [T]로 지정하면 된다. (예: `AsyncState<List<Note>>`)
sealed class AsyncState<T> extends Equatable {
  const AsyncState();

  const factory AsyncState.initial() = AsyncInitial<T>;
  const factory AsyncState.loading() = AsyncLoading<T>;
  const factory AsyncState.success(T data) = AsyncSuccess<T>;
  const factory AsyncState.failure() = AsyncFailure<T>;

  @override
  List<Object?> get props => [];
}

final class AsyncInitial<T> extends AsyncState<T> {
  const AsyncInitial();
}

final class AsyncLoading<T> extends AsyncState<T> {
  const AsyncLoading();
}

final class AsyncSuccess<T> extends AsyncState<T> {
  const AsyncSuccess(this.data);

  final T data;

  @override
  List<Object?> get props => [data];
}

final class AsyncFailure<T> extends AsyncState<T> {
  const AsyncFailure();
}
