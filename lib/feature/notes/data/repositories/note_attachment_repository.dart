import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';

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
  /// 보낸 비율(0~1)을 받는다.
  ///
  /// 어떤 형식을 받을지는 서버가 정한다. 서버는 받지 않는 형식이면 업로드 주소를 주지
  /// 않고 400 으로 거절하므로, 파일을 올리기 전에 끝난다.
  Future<NoteAttachment> upload(
    int channelId,
    NoteUploadFile file, {
    void Function(double progress)? onProgress,
  }) async {
    final contentType = contentTypeOf(file.name);

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

  /// 업로드 주소를 받을 때 신고할 MIME 타입. 이름의 확장자로 정한다.
  ///
  /// Android 파일 선택기는 MIME 을 주지 않아 이름으로 알아낸다. 모르는 확장자면
  /// `application/octet-stream` 을 보내 서버가 받을지 정하게 한다.
  @visibleForTesting
  static String contentTypeOf(String name) {
    final type = lookupMimeType(name) ?? 'application/octet-stream';
    return _serverAliases[type] ?? type;
  }

  /// 같은 형식인데 `mime` 패키지와 서버(cowork-chat)가 다르게 부르는 이름.
  ///
  /// 서버는 형식 이름을 글자 그대로 비교하므로, 서버가 쓰는 이름으로 바꿔 보낸다.
  /// 어떤 형식을 받을지는 바꾸지 않는다. 서버가 두 이름을 다 받게 되면 지운다.
  static const _serverAliases = {'audio/x-wav': 'audio/wav'};

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
