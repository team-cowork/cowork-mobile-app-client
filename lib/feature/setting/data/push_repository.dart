import 'package:dio/dio.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/dio_client.dart';
import '../../auth/data/auth_repository.dart';

/// 이 기기의 푸시 수신을 notification 서비스에 등록·해제한다.
///
/// 서버는 FCM 토큰이 아니라 Firebase installation ID(FID)로 기기를 구분한다.
class PushRepository {
  PushRepository(AuthRepository auth)
    : this.withDio(
        createAuthedDio(ApiService.notification, auth),
        const FirebasePushDevice(),
      );

  PushRepository.withDio(this._dio, this._device);

  final Dio _dio;
  final PushDevice _device;

  /// 알림 권한을 받아 이 기기를 등록한다. 사용자가 권한을 거절하면 false.
  Future<bool> enable() async {
    if (!await _device.requestPermission()) return false;
    await _dio.post<String>(
      '/notifications/installations',
      data: {
        'fid': await _device.installationId(),
        'platform': _device.platform,
      },
    );
    return true;
  }

  Future<void> disable() async => _dio.delete<String>(
    '/notifications/installations/${await _device.installationId()}',
  );
}

/// 푸시에 필요한 기기 쪽 기능. 테스트에서 Firebase 없이 갈아끼우려고 뺐다.
abstract interface class PushDevice {
  Future<bool> requestPermission();

  Future<String> installationId();

  /// 서버 `platform` 값(`ANDROID` / `IOS`).
  String get platform;
}

class FirebasePushDevice implements PushDevice {
  const FirebasePushDevice();

  @override
  Future<bool> requestPermission() async {
    _ensureConfigured();
    final settings = await FirebaseMessaging.instance.requestPermission();
    return switch (settings.authorizationStatus) {
      AuthorizationStatus.authorized || AuthorizationStatus.provisional => true,
      _ => false,
    };
  }

  @override
  Future<String> installationId() {
    _ensureConfigured();
    return FirebaseInstallations.instance.getId();
  }

  @override
  String get platform =>
      defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID';

  /// `google-services.json` 이 없는 빌드는 [Firebase.initializeApp] 이 실패한
  /// 채로 뜬다. 그때 플러그인이 던지는 낯선 예외 대신 사유가 분명한 예외를 낸다.
  static void _ensureConfigured() {
    if (Firebase.apps.isEmpty) {
      throw const PushUnavailableException();
    }
  }
}

/// Firebase 설정 없이 빌드돼 푸시를 쓸 수 없을 때.
class PushUnavailableException implements Exception {
  const PushUnavailableException();

  @override
  String toString() => 'PushUnavailableException: Firebase 가 초기화되지 않았다';
}
