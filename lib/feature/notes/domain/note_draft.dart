import 'note_template.dart';

/// 새 노트 시트에서 고른 값. 아직 서버에 없는 회의록이다.
///
/// 편집 화면에서 처음 저장할 때 이 값으로 회의록을 만든다. 시트에서 바로 만들면
/// 내용을 쓰지 않고 나갔을 때 빈 회의록이 남는다.
typedef NoteDraft = ({int channelId, NoteTemplate template, String title});
