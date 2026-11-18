import 'package:dio/dio.dart';
import 'package:mime/mime.dart';

import '../../../../core/network/dio_client.dart';
import '../../../../shared/domain/upload_file.dart';
import '../../../auth/data/auth_repository.dart';
import '../model/requests/confirm_file_upload_request.dart';
import '../model/requests/file_upload_url_request.dart';
import '../model/responses/confirmed_file_response.dart';
import '../model/responses/file_upload_url_response.dart';

/// 채널에 파일을 올리는 저장소.
///
/// 채팅 첨부와 회의록 첨부가 같이 쓴다. 둘 다 파일을 채널에 올려 확정 키를 받은 뒤,
/// 그 키를 메시지나 회의록 저장 요청의 `attachments` 에 싣는다.
class ChatFileRepository {
  ChatFileRepository(AuthRepository auth)
    : this.withDio(
        chat: createAuthedDio(ApiService.chat, auth),
        uploader: createDio(ApiService.chat),
      );

  ChatFileRepository.withDio({required Dio chat, required Dio uploader})
    : _chat = chat,
      _uploader = uploader;

  final Dio _chat;

  /// 파일을 스토리지 주소로 직접 올릴 때 쓰는 dio.
  ///
  /// 인증 dio 를 쓰면 인터셉터가 Authorization 을 붙이는데, 서명에 없는 헤더가 섞이면
  /// 스토리지가 요청을 거부한다. 그래서 인증 없는 dio 로 따로 보낸다.
  final Dio _uploader;

  /// [file] 을 [channelId] 채널에 올리고 확정한다.
  ///
  /// 업로드 주소 발급 → 스토리지 PUT → 업로드 확인 3단계다. [onProgress] 는 PUT 이
  /// 보낸 비율(0~1)을 받는다.
  ///
  /// 어떤 형식·크기를 받을지는 서버가 정한다. 서버는 받지 않는 파일이면 업로드 주소를
  /// 주지 않고 거절하므로(크기 초과는 413), 파일을 올리기 전에 끝난다.
  Future<ConfirmedFileResponse> upload(
    int channelId,
    UploadFile file, {
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
    return confirmed.name.isEmpty
        ? confirmed.copyWith(name: file.name)
        : confirmed;
  }

  /// 업로드 주소를 받을 때 신고할 MIME 타입. 이름의 확장자로 정한다.
  ///
  /// Android 파일 선택기는 MIME 을 주지 않아 이름으로 알아낸다. 모르는 확장자면
  /// `application/octet-stream` 을 보내 서버가 받을지 정하게 한다.
  static String contentTypeOf(String name) {
    final type = lookupMimeType(name) ?? 'application/octet-stream';
    return _serverAliases[type] ?? type;
  }

  /// 같은 형식인데 `mime` 패키지와 서버(cowork-chat)가 다르게 부르는 이름.
  ///
  /// 서버는 형식 이름을 글자 그대로 비교하므로, 서버가 쓰는 이름으로 바꿔 보낸다.
  /// 어떤 형식을 받을지는 바꾸지 않는다. 서버가 두 이름을 다 받게 되면 지운다.
  static const _serverAliases = {'audio/x-wav': 'audio/wav'};
}
