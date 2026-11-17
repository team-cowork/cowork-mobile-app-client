import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/note.dart';
import '../../domain/note_attachment.dart';
import '../model/requests/confirm_file_upload_request.dart';
import '../model/requests/file_upload_url_request.dart';
import '../model/responses/confirmed_file_response.dart';
import '../model/responses/file_upload_url_response.dart';

/// 회의록 첨부파일 저장소.
///
/// 회의록 API 는 파일을 직접 받지 않는다. 파일은 회의록 채널에 채팅 첨부처럼 올리고
/// (chat 서비스 `files/*`), 확정된 키를 회의록 저장 요청의 `attachments` 에 싣는다.
/// 받을 때는 회의록 경로로 임시 주소를 받는다. 주소는 channel 서비스 아래지만
/// 게이트웨이가 chat 서비스로 보낸다.
class NoteAttachmentRepository {
  NoteAttachmentRepository(AuthRepository auth)
    : this.withDio(
        chat: createAuthedDio(ApiService.chat, auth),
        channel: createAuthedDio(ApiService.channel, auth),
        uploader: createDio(ApiService.chat),
      );

  NoteAttachmentRepository.withDio({
    required Dio chat,
    required Dio channel,
    required Dio uploader,
  }) : _chat = chat,
       _channel = channel,
       _uploader = uploader;

  final Dio _chat;
  final Dio _channel;

  /// 파일을 스토리지 주소로 직접 올릴 때 쓰는 dio.
  ///
  /// 인증 dio 를 쓰면 인터셉터가 Authorization 을 붙이는데, 서명에 없는 헤더가 섞이면
  /// 스토리지가 요청을 거부한다. 그래서 인증 없는 dio 로 따로 보낸다.
  final Dio _uploader;

  /// [file] 을 [channelId] 채널에 올리고 회의록에 붙일 수 있게 확정한다.
  ///
  /// 업로드 주소 발급 → 스토리지 PUT → 업로드 확인 3단계다. [onProgress] 는 PUT 이
  /// 보낸 비율(0~1)을 받는다. 형식은 [noteAttachmentContentTypes] 에 있는 것만 받으며,
  /// 거르는 일은 부르는 쪽이 먼저 한다.
  Future<NoteAttachment> upload(
    int channelId,
    NoteUploadFile file, {
    void Function(double progress)? onProgress,
  }) async {
    final contentType = noteAttachmentContentTypes[extensionOf(file.name)];
    if (contentType == null) {
      throw ArgumentError.value(file.name, 'file', '첨부할 수 없는 형식');
    }

    final target = FileUploadUrlResponse.fromJson(
      unwrapPayload(
        (await _chat.post<String>(
              '/chat/channels/$channelId/files/presigned-url',
              data: FileUploadUrlRequest(
                filename: file.name,
                contentType: contentType,
                size: file.size,
              ).toJson(),
            )).data ??
            '',
      ),
    );

    // 스트림은 길이를 모르면 chunked 로 가는데, 스토리지 PUT 은 길이를 요구한다.
    // 서명에 든 Content-Type 은 발급 때 보낸 값과 같아야 해서 응답 헤더를 우선한다.
    await _uploader.put<void>(
      target.uploadUrl,
      data: file.read(),
      options: Options(
        contentType: target.headers['Content-Type'] ?? contentType,
        headers: {Headers.contentLengthHeader: file.size},
      ),
      onSendProgress: onProgress == null
          ? null
          : (sent, _) => onProgress(sent / file.size),
    );

    final confirmed = ConfirmedFileResponse.fromJson(
      unwrapPayload(
        (await _chat.post<String>(
              '/chat/channels/$channelId/files/confirm',
              data: ConfirmFileUploadRequest(
                objectKey: target.objectKey,
              ).toJson(),
            )).data ??
            '',
      ),
    );
    return NoteAttachment(
      objectKey: confirmed.objectKey,
      name: confirmed.name.isEmpty ? file.name : confirmed.name,
    );
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
