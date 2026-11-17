import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/network/http_error_message.dart';
import '../../../../core/utils/logger.dart';
import '../../data/repositories/message_repository.dart';

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

/// 채팅 첨부파일을 누르면 그때마다 서버에서 임시 주소(60초)를 새로 받아 바로 연다.
/// 주소를 저장해 두면 만료되므로 들고 있지 않는다. 받는 동안 다시 눌러도 요청이
/// 겹치지 않게 한다.
class AttachmentOpener {
  AttachmentOpener({
    required MessageRepository repository,
    UrlOpener open = launchExternally,
  }) : _repository = repository,
       _open = open;

  static const _fallback = '파일을 열지 못했어요.';

  final MessageRepository _repository;
  final UrlOpener _open;
  bool _busy = false;

  /// [messageId] 메시지의 [attachmentIndex] 번째 첨부파일을 연다. 이미 여는 중이거나
  /// 잘 열렸으면 null, 실패했으면 사용자에게 보일 사유를 돌려준다.
  Future<String?> open(
    int channelId,
    String messageId,
    int attachmentIndex,
  ) async {
    if (_busy) return null;
    _busy = true;
    try {
      final url = await _repository.fetchAttachmentDownloadUrl(
        channelId,
        messageId,
        attachmentIndex,
      );
      return await _open(Uri.parse(url)) ? null : '파일을 열 수 있는 앱이 없어요.';
    } catch (e, s) {
      Logger.e('첨부파일 열기 실패', tag: 'Chat', error: e, stackTrace: s);
      return failureMessageOf(e, _fallback) ?? _fallback;
    } finally {
      _busy = false;
    }
  }
}
