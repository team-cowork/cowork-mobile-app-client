/// 갤러리에서 고른 사진 [path] 의 MIME 타입. presigned 업로드(프로필 사진·팀 아이콘)에
/// 실어 보낸다.
///
/// 확장자를 못 알아보면 jpeg 로 본다. 갤러리에서 오는 사진의 대부분이다. 받을 수 있는
/// 형식인지는 서버가 정하므로 여기서 거르지 않는다.
String imageContentTypeOf(String path) =>
    switch (path.split('.').last.toLowerCase()) {
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      _ => 'image/jpeg',
    };
