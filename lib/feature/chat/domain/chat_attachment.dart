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

  @override
  List<Object?> get props => [name, size, mimeType];
}
