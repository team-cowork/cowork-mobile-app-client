import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// 받은 주소를 기기의 외부 앱·브라우저로 연다. 열 수 없으면 false.
typedef UrlOpener = Future<bool> Function(Uri url);

/// 기본 [UrlOpener]. Android 는 열 앱이 없으면 false 대신 `ACTIVITY_NOT_FOUND` 를
/// 던지므로, 두 플랫폼이 같은 계약(열 수 없으면 false)을 따르게 맞춘다.
Future<bool> launchExternally(Uri url) async {
  try {
    return await launchUrl(url, mode: LaunchMode.externalApplication);
  } on PlatformException catch (e) {
    if (e.code == 'ACTIVITY_NOT_FOUND') return false;
    rethrow;
  }
}
