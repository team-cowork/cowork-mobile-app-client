import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/logger.dart';
import '../../../../../network/http_error_message.dart';
import '../../../data/profile_repository.dart';
import '../../../data/user_request.dart';

part 'profile_status_event.dart';
part 'profile_status_state.dart';

/// 상태 설정 시트의 저장을 맡는 Bloc.
///
/// 실패해도 시트를 닫지 않고 사유를 보여 준다. 프로필 화면 상태와 섞으면 저장
/// 실패가 프로필 전체를 에러 화면으로 바꾸므로, 시트 안에서 따로 든다.
class ProfileStatusBloc extends Bloc<ProfileStatusEvent, ProfileStatusState> {
  ProfileStatusBloc(this._repository) : super(const ProfileStatusState()) {
    on<ProfileStatusSubmitted>(_onSubmit);
  }

  final ProfileRepository _repository;

  /// 사용자가 고른 상태를 그대로 `custom_status` 로 보낸다. 메시지가 비면 null 로
  /// 보내 서버 값을 지운다.
  Future<void> _onSubmit(
    ProfileStatusSubmitted event,
    Emitter<ProfileStatusState> emit,
  ) async {
    emit(const ProfileStatusState(saving: true));
    try {
      await _repository.updateStatus(
        UpdateStatusRequest(
          customStatus: event.customStatus,
          message: event.message.isEmpty ? null : event.message,
        ),
      );
      emit(const ProfileStatusState(saved: true));
    } catch (e, s) {
      Logger.e('상태 저장 실패', tag: 'Profile', error: e, stackTrace: s);
      emit(
        ProfileStatusState(
          error: e is DioException ? dioErrorMessage(e) : '상태를 저장하지 못했어요.',
        ),
      );
    }
  }
}
