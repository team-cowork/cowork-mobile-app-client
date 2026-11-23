/// 올리려고 고른 파일. 아직 서버에 없다.
///
/// 크기는 업로드 주소를 받을 때 서버에 미리 알려야 하고, 실제 올린 크기와 다르면
/// 서버가 거절한다. [read] 는 부를 때마다 처음부터 읽는 새 스트림을 준다. 큰 파일을
/// 통째로 메모리에 올리지 않으려고 바이트 대신 스트림을 들고 다닌다.
typedef UploadFile = ({
  String name,
  int size,
  Stream<List<int>> Function() read,
});
