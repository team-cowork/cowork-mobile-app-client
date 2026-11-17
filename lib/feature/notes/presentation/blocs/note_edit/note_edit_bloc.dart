import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/repositories/note_attachment_repository.dart';
import '../../../data/repositories/notes_repository.dart';
import '../../../data/repositories/note_template_repository.dart';
import '../../../domain/note.dart';
import '../../../domain/note_attachment.dart';
import '../../../domain/note_draft.dart';
import '../../../domain/note_section_field.dart';
import '../../../domain/note_template.dart';

part 'note_edit_event.dart';
part 'note_edit_state.dart';

/// 회의록 편집 화면의 입력 칸과 저장 흐름을 관리하는 Bloc.
///
/// 회의록이 쓴 템플릿을 읽어 섹션 순서·형식·필수 여부대로 입력 칸을 만들고, 저장
/// 시 필수 섹션을 확인한 뒤 서버에 올린다. 새 회의록이면 그때 만든다.
///
/// 첨부는 파일을 고르는 즉시 올리고, 회의록에는 저장할 때 목록째 반영한다. 업로드에는
/// 회의록 id 가 필요 없어서(채널만 있으면 된다) 아직 만들어지지 않은 새 회의록에도
/// 붙일 수 있다. 저장하지 않고 나가면 붙지 않은 업로드는 서버가 나중에 지운다.
class NoteEditBloc extends Bloc<NoteEditEvent, NoteEditState> {
  /// 이미 있는 [note] 를 고친다. 템플릿은 [NoteEditStarted] 때 읽는다.
  NoteEditBloc(
    Note note,
    NotesRepository repository,
    NoteTemplateRepository templates,
    NoteAttachmentRepository attachments,
  ) : this._(note, null, repository, templates, attachments);

  /// 새 노트 시트에서 고른 [draft] 로 새 회의록을 쓴다. [author] 는 메타 줄에 보일
  /// 로그인 사용자다. 서버에는 처음 저장할 때 만들므로 그 전까지 id 는 0 이다.
  NoteEditBloc.create(
    NoteDraft draft,
    NoteAuthor author,
    NotesRepository repository,
    NoteTemplateRepository templates,
    NoteAttachmentRepository attachments,
  ) : this._(
        Note(
          id: 0,
          channelId: draft.channelId,
          templateId: draft.template.id,
          title: draft.title,
          tags: const [],
          author: author,
        ),
        draft.template,
        repository,
        templates,
        attachments,
      );

  NoteEditBloc._(
    Note note,
    this._draftTemplate,
    this._repository,
    this._templates,
    this._attachments,
  ) : super(NoteEditState(note: note)) {
    on<NoteEditStarted>(_onStart);
    on<NoteEditSaved>(_onSave);
    on<NoteEditAttachmentAdded>(_onAttachmentAdded);
    on<NoteEditAttachmentRemoved>(_onAttachmentRemoved);
  }

  /// 서버가 한 회의록에 받는 첨부 수.
  static const maxAttachments = 20;

  /// 새 회의록이면 시트에서 고른 템플릿. 이미 있는 회의록이면 null 이다.
  final NoteTemplate? _draftTemplate;

  final NotesRepository _repository;
  final NoteTemplateRepository _templates;
  final NoteAttachmentRepository _attachments;

  /// 저장 요청이 오가는 중인지. 새 회의록에서 저장을 연달아 누르면 회의록이 둘
  /// 생기므로 그동안 들어온 저장은 버린다.
  bool _saving = false;

  /// 다음 업로드에 매길 번호.
  int _nextUploadId = 0;

  bool get _isNew => _draftTemplate != null;

  /// 템플릿을 못 읽어도 편집은 막지 않는다. 본문에 있는 섹션은 그대로 고칠 수 있다.
  Future<void> _onStart(
    NoteEditStarted event,
    Emitter<NoteEditState> emit,
  ) async {
    final note = state.note;
    var template = _draftTemplate;
    if (template == null) {
      try {
        template = await _templates.fetchTemplate(
          note.channelId,
          note.templateId,
        );
      } catch (e, s) {
        Logger.e('회의록 템플릿 조회 실패', tag: 'Notes', error: e, stackTrace: s);
      }
    }
    emit(
      NoteEditState(
        note: note,
        fields: sectionFieldsOf(template, note.sections),
        templateName: template?.name,
        templateMissing: template == null,
      ),
    );
  }

  Future<void> _onSave(NoteEditSaved event, Emitter<NoteEditState> emit) async {
    if (_saving) return;

    // 지난 실패 사유를 먼저 지운다. 같은 사유로 또 실패하면 상태가 같아 화면이
    // 다시 알림을 띄우지 못하기 때문이다.
    emit(state.copyWith());

    // 서버는 필수 섹션을 검사하지 않으므로 여기서 막는다.
    final missing = [
      for (final field in state.fields ?? const <NoteSectionField>[])
        if (field.isRequired &&
            (event.sections[field.title] ?? '').trim().isEmpty)
          field.title,
    ];
    if (missing.isNotEmpty) {
      emit(state.copyWith(error: '필수 섹션을 채워 주세요: ${missing.join(', ')}'));
      return;
    }

    // 올리는 중인 파일은 아직 확정 키가 없어 목록에 실을 수 없다. 그냥 저장하면
    // 사용자가 붙였다고 믿은 파일이 빠진 채 저장된다.
    if (state.uploads.isNotEmpty) {
      emit(state.copyWith(error: '파일을 다 올린 뒤에 저장해 주세요.'));
      return;
    }

    var edited = state.note.copyWith(
      title: event.title,
      // 빈 섹션은 빼서 서버에 빈 키가 쌓이지 않게 한다.
      sections: {
        for (final MapEntry(:key, :value) in event.sections.entries)
          if (value.trim().isNotEmpty) key: value,
      },
    );
    _saving = true;
    try {
      if (_isNew) {
        // 서버가 정한 id·작성자로 바꿔 둔다. 화면을 닫으며 이 회의록을 돌려준다.
        edited = await _repository.createNote(edited);
      } else {
        await _repository.updateNote(edited);
      }
      emit(state.copyWith(note: edited, saved: true));
    } catch (e, s) {
      Logger.e('회의록 저장 실패', tag: 'Notes', error: e, stackTrace: s);
      emit(state.copyWith(error: failureMessageOf(e, '회의록을 저장하지 못했어요.')));
    } finally {
      _saving = false;
    }
  }

  /// 고른 파일을 올린다. 여러 파일을 연달아 고르면 동시에 올라간다.
  Future<void> _onAttachmentAdded(
    NoteEditAttachmentAdded event,
    Emitter<NoteEditState> emit,
  ) async {
    final file = event.file;
    // 지난 실패 사유를 지운다. 같은 사유가 이어져도 알림이 다시 뜨게 한다.
    emit(state.copyWith());

    final problem = _whyNotAttachable(file);
    if (problem != null) {
      emit(state.copyWith(error: problem));
      return;
    }

    final id = _nextUploadId++;
    emit(
      state.copyWith(
        uploads: [
          ...state.uploads,
          NoteUpload(id: id, name: file.name),
        ],
      ),
    );

    // 진행률 콜백은 조각마다 오므로 1% 단위로 바뀔 때만 그린다.
    var shownPercent = 0;
    void onProgress(double progress) {
      final percent = (progress * 100).floor();
      if (percent == shownPercent) return;
      shownPercent = percent;
      emit(
        state.copyWith(
          uploads: [
            for (final upload in state.uploads)
              upload.id == id ? upload.copyWith(progress: progress) : upload,
          ],
        ),
      );
    }

    List<NoteUpload> remaining() => [
      for (final upload in state.uploads)
        if (upload.id != id) upload,
    ];
    try {
      final attachment = await _attachments.upload(
        state.note.channelId,
        file,
        onProgress: onProgress,
      );
      emit(
        state.copyWith(
          note: state.note.copyWith(
            attachments: [...state.note.attachments, attachment],
          ),
          uploads: remaining(),
        ),
      );
    } catch (e, s) {
      Logger.e('첨부파일 업로드 실패', tag: 'Notes', error: e, stackTrace: s);
      emit(
        state.copyWith(
          uploads: remaining(),
          error: failureMessageOf(e, '파일을 올리지 못했어요.'),
        ),
      );
    }
  }

  /// 올리기 전에 걸러 낼 수 있는 사유. 올려도 되면 null.
  ///
  /// 형식과 개수는 서버도 거절하지만, 업로드까지 마친 뒤 저장할 때에야 알게 되는
  /// 것보다 고르는 자리에서 알려 주는 편이 낫다. 크기 한도는 서버 설정이라 서버가
  /// 업로드 주소를 줄 때 거절하게 둔다.
  String? _whyNotAttachable(NoteUploadFile file) {
    if (_saving) return '저장하는 중이에요. 저장한 뒤 다시 붙여 주세요.';
    if (state.note.attachments.length + state.uploads.length >=
        maxAttachments) {
      return '첨부파일은 $maxAttachments개까지 붙일 수 있어요.';
    }
    if (!noteAttachmentContentTypes.containsKey(extensionOf(file.name))) {
      return '이미지·영상·오디오·PDF·텍스트 파일만 붙일 수 있어요.';
    }
    if (file.size <= 0) return '빈 파일은 붙일 수 없어요.';
    return null;
  }

  void _onAttachmentRemoved(
    NoteEditAttachmentRemoved event,
    Emitter<NoteEditState> emit,
  ) {
    emit(
      state.copyWith(
        note: state.note.copyWith(
          attachments: [
            for (final attachment in state.note.attachments)
              if (attachment != event.attachment) attachment,
          ],
        ),
      ),
    );
  }
}
