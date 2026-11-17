import 'package:dio/dio.dart';

import '../../../core/network/dio_client.dart';
import '../../auth/data/auth_repository.dart';
import '../../channel/domain/channel_notification.dart';
import '../domain/enums/notification_level.dart';
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

  /// 알림 수준만 보낸다. 서버는 보낸 항목만 바꾸고 나머지는 유지한 뒤 저장된
  /// 설정을 돌려준다.
  ///
  /// 부분 수정은 계정 설정(`/preferences/account/{id}`)에만 해당한다. 채널 알림
  /// 설정(`.../channels/{channelId}/notification`)의 PUT 은 설정 전체를 교체한다.
  Future<AccountPreference> updateNotificationLevel(
    int accountId,
    NotificationLevel level,
  ) async => _parse(
    await _dio.put<String>(
      '/preferences/account/$accountId',
      data: {'notification_level': level.value},
    ),
  );

  /// 이 채널에 정해 둔 내 알림 설정. 정한 적이 없으면 수준이 null 이다.
  Future<ChannelNotification> fetchChannelNotification(
    int accountId,
    int channelId,
  ) async => _parseChannelNotification(
    await _dio.get<String>(_channelNotification(accountId, channelId)),
  );

  /// 채널 알림 설정을 통째로 바꾼다. 서버가 저장된 설정을 돌려준다.
  Future<ChannelNotification> updateChannelNotification(
    int accountId,
    int channelId,
    ChannelNotification notification,
  ) async => _parseChannelNotification(
    await _dio.put<String>(
      _channelNotification(accountId, channelId),
      data: {
        'notification_level': notification.level?.value ?? 'DEFAULT',
        'muted_until': notification.mutedUntil?.toUtc().toIso8601String(),
      },
    ),
  );

  static String _channelNotification(int accountId, int channelId) =>
      '/preferences/account/$accountId/channels/$channelId/notification';

  static ChannelNotification _parseChannelNotification(
    Response<String> response,
  ) {
    final json = unwrapPayload(response.data ?? '');
    final level = json['notification_level'];
    final mutedUntil = json['muted_until'];
    return ChannelNotification(
      level: NotificationLevel.values
          .where((candidate) => candidate.value == level)
          .firstOrNull,
      mutedUntil: mutedUntil is String ? DateTime.tryParse(mutedUntil) : null,
    );
  }

  static AccountPreference _parse(Response<String> response) =>
      AccountPreference.fromJson(unwrapPayload(response.data ?? ''));
}
