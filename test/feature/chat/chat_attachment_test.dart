import 'package:cowork_app/feature/chat/domain/chat_attachment.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ChatAttachment image(int size) =>
      ChatAttachment(name: '사진.png', size: size, mimeType: 'image/png');

  test('미리보기 한도와 크기가 같은 이미지까지 대화 안에서 바로 그린다', () {
    expect(image(ChatAttachment.maxPreviewSize).isPreviewableImage, isTrue);
    expect(
      image(ChatAttachment.maxPreviewSize + 1).isPreviewableImage,
      isFalse,
    );
  });
}
