import '../../../../core/network/http_error_message.dart';
import '../../../../core/utils/logger.dart';
import '../../../../shared/utils/external_url.dart';
import '../../data/repositories/message_repository.dart';

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
