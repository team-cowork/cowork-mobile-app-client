import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../auth/data/auth_repository.dart';
import 'account_preference.dart';

/// preference 서비스의 계정 설정을 다루는 저장소.
///
/// 서버는 본인 계정만 허용하지만 경로에 계정 id 를 받으므로, 부르는 쪽이
/// `/users/me` 의 id 를 넘긴다.
class PreferenceRepository {
  PreferenceRepository(AuthRepository auth)
    : this.withDio(createAuthedDio(ApiService.preference, auth));

  PreferenceRepository.withDio(this._dio);

  final Dio _dio;

  Future<AccountPreference> fetchAccount(int accountId) async =>
      _parse(await _dio.get<String>('/preferences/account/$accountId'));

  /// 서버가 저장된 설정을 그대로 돌려준다.
  Future<AccountPreference> updateAccount(
    int accountId,
    AccountPreference preference,
  ) async => _parse(
    await _dio.put<String>(
      '/preferences/account/$accountId',
      data: preference.toJson(),
    ),
  );

  static AccountPreference _parse(Response<String> response) =>
      AccountPreference.fromJson(unwrapPayload(response.data ?? ''));
}
