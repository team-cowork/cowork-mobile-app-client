import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../shared/domain/upload_file.dart';
import '../../../auth/data/auth_repository.dart';
import '../../../chat/data/repositories/chat_file_repository.dart';
import '../../domain/note.dart';
import '../../domain/note_attachment.dart';

/// 회의록 첨부파일 저장소.
///
/// 회의록 API 는 파일을 직접 받지 않는다. 파일은 회의록 채널에 채팅 첨부처럼 올리고
/// ([ChatFileRepository]), 확정된 키를 회의록 저장 요청의 `attachments` 에 싣는다.
/// 받을 때는 회의록 경로로 임시 주소를 받는다. 주소는 channel 서비스 아래지만
/// 게이트웨이가 chat 서비스로 보낸다.
class NoteAttachmentRepository {
  NoteAttachmentRepository(
    AuthRepository auth, {
    required ChatFileRepository files,
  }) : this.withDio(
         files: files,
         channel: createAuthedDio(ApiService.channel, auth),
       );

  NoteAttachmentRepository.withDio({
    required ChatFileRepository files,
    required Dio channel,
  }) : _files = files,
       _channel = channel;

  final ChatFileRepository _files;
  final Dio _channel;

  /// [file] 을 [channelId] 채널에 올리고 회의록에 붙일 수 있게 확정한다.
  ///
  /// [onProgress] 는 파일을 보낸 비율(0~1)을 받는다.
  Future<NoteAttachment> upload(
    int channelId,
    UploadFile file, {
    void Function(double progress)? onProgress,
  }) async {
    final confirmed = await _files.upload(
      channelId,
      file,
      onProgress: onProgress,
    );
    return NoteAttachment(objectKey: confirmed.objectKey, name: confirmed.name);
  }

  /// [note] 에 붙은 [attachment] 를 받을 임시 주소.
  ///
  /// 서버는 누를 때마다 채널 권한을 다시 확인하고 60초만 유효한 주소를 준다. 영구
  /// 주소가 없으므로 받은 주소는 저장하지 않고 바로 쓴다.
  Future<String> fetchDownloadUrl(Note note, NoteAttachment attachment) async {
    final url = unwrapPayload(
      (await _channel.get<String>(
            '/channels/${note.channelId}/meeting-notes/${note.id}'
            '/attachments/download-url',
            queryParameters: {'objectKey': attachment.objectKey},
          )).data ??
          '',
    )['downloadUrl'];
    if (url is! String || url.isEmpty) {
      throw const FormatException('다운로드 주소가 응답에 없다');
    }
    return url;
  }
}
