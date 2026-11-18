import 'package:freezed_annotation/freezed_annotation.dart';

part 'file_upload_url_request.freezed.dart';
part 'file_upload_url_request.g.dart';

/// `POST /chat/channels/{channelId}/files/presigned-url` 요청 본문.
///
/// 서버는 여기서 신고한 형식·크기를 업로드 확인 때 실제 파일과 비교하므로, 올릴
/// 파일과 똑같은 값을 보내야 한다.
@Freezed(fromJson: false, toJson: true)
abstract class FileUploadUrlRequest with _$FileUploadUrlRequest {
  const factory FileUploadUrlRequest({
    required String filename,
    required String contentType,

    /// 바이트 단위. 서버는 1 이상만 받는다.
    required int size,
  }) = _FileUploadUrlRequest;
}
