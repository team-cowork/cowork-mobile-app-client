import 'package:freezed_annotation/freezed_annotation.dart';

part 'attachment_response.freezed.dart';
part 'attachment_response.g.dart';

/// 메시지 첨부파일 하나. 화면에서 쓰는 필드만 옮긴다.
@freezed
abstract class AttachmentResponse with _$AttachmentResponse {
  @JsonSerializable(checked: true)
  const factory AttachmentResponse({
    @Default('') String name,

    /// 바이트 단위.
    @Default(0) int size,
    @Default('') String mimeType,
  }) = _AttachmentResponse;

  factory AttachmentResponse.fromJson(Map<String, dynamic> json) =>
      _$AttachmentResponseFromJson(json);
}
