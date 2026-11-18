import '../../../../shared/domain/upload_file.dart';

/// 첨부할 파일 하나를 고른다. 사용자가 취소하면 null.
///
/// 테스트가 기기 파일 선택 창 대신 가짜 파일을 넣을 수 있게 함수로 받는다. 기본값은
/// `pickUploadFile`(`shared/utils/file_picking.dart`).
typedef NoteFilePicker = Future<UploadFile?> Function();
