import 'package:equatable/equatable.dart';

/// 메시지에 붙은 파일 하나.
class ChatAttachment extends Equatable {
  const ChatAttachment({
    required this.name,
    required this.size,
    required this.mimeType,
  });

  final String name;

  /// 바이트 단위.
  final int size;
  final String mimeType;

  /// 대화 안에서 바로 그려 볼 수 있는 이미지. 앱이 풀 수 있는 형식이고 너무 크지 않은 것만
  /// 이고, 나머지 이미지는 다른 파일처럼 카드로 보인다.
  bool get isPreviewableImage =>
      _previewableTypes.contains(mimeType.toLowerCase()) &&
      size <= maxPreviewSize;

  static const maxPreviewSize = 10 * 1024 * 1024;
  static const _previewableTypes = {
    'image/png',
    'image/jpeg',
    'image/gif',
    'image/webp',
    'image/bmp',
  };

  @override
  List<Object?> get props => [name, size, mimeType];
}
