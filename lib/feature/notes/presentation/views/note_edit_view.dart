import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/logger.dart';
import '../../../../shared/domain/upload_file.dart';
import '../../../../shared/utils/file_picking.dart';
import '../../../../shared/widgets/base_scaffold.dart';
import '../../../profile/data/profile_store.dart';
import '../../data/repositories/note_attachment_repository.dart';
import '../../data/repositories/notes_repository.dart';
import '../../data/repositories/note_template_repository.dart';
import '../../domain/enums/note_section_type.dart';
import '../../domain/note.dart';
import '../../domain/note_draft.dart';
import '../../domain/note_section_field.dart';
import '../blocs/note_edit/note_edit_bloc.dart';
import '../utils/note_file_picker.dart';
import '../widgets/note_attachment_card.dart';

/// 회의록 편집 화면.
///
/// Figma `App / 노트 편집 — 템플릿 섹션` 스펙에 맞춘 다크 전용 레이아웃.
/// 회의록이 쓴 템플릿의 섹션을 순서대로 그리고, 섹션 형식에 맞는 입력 칸을 둔다.
/// 하단 서식 툴바는 포커스된 입력창에 마크다운을 삽입하고, 클립 버튼은 파일을 붙인다.
class NoteEditView extends StatelessWidget {
  /// 이미 있는 [note] 를 고친다.
  const NoteEditView({
    super.key,
    required Note this.note,
    this.pickFile = pickUploadFile,
  }) : draft = null;

  /// 새 노트 시트에서 고른 [draft] 로 새 회의록을 쓴다. 저장하면 그때 만들어진다.
  const NoteEditView.create({
    super.key,
    required NoteDraft this.draft,
    this.pickFile = pickUploadFile,
  }) : note = null;

  final Note? note;
  final NoteDraft? draft;

  /// 첨부할 파일을 고르는 창. 테스트는 가짜 파일을 넣는다.
  final NoteFilePicker pickFile;

  static const _title = '📝 회의록';

  /// 새 회의록 메타 줄의 작성자. 서버가 정하기 전이라 로그인 사용자로 채운다.
  static NoteAuthor _me() {
    final profile = ProfileStore.instance;
    final today = DateTime.now();
    return NoteAuthor(
      authorId: profile.currentUserId ?? 0,
      name: profile.name,
      initial: profile.avatarInitial,
      avatarUrl: profile.avatarUrl,
      date:
          '${today.month.toString().padLeft(2, '0')}.'
          '${today.day.toString().padLeft(2, '0')}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final notes = context.read<NotesRepository>();
        final templates = context.read<NoteTemplateRepository>();
        final attachments = context.read<NoteAttachmentRepository>();
        return switch (draft) {
          final draft? => NoteEditBloc.create(
            draft,
            _me(),
            notes,
            templates,
            attachments,
          ),
          null => NoteEditBloc(note!, notes, templates, attachments),
        }..add(const NoteEditStarted());
      },
      child: BlocConsumer<NoteEditBloc, NoteEditState>(
        // 저장이 끝나면 갱신된(새 회의록이면 만들어진) 노트를 들고 돌아간다.
        // 실패하면 화면을 열어 둔 채 사유만 알린다.
        listenWhen: (previous, current) =>
            current.saved || current.error != null,
        listener: (context, state) {
          final error = state.error;
          if (error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(error)));
            return;
          }
          context.pop(state.note);
        },
        // 입력 칸은 템플릿을 읽은 뒤 한 번만 만든다. 저장이 실패해 상태가 바뀔
        // 때마다 폼을 다시 만들면 입력값이 사라진다.
        buildWhen: (previous, current) => previous.fields != current.fields,
        builder: (context, state) {
          final fields = state.fields;
          if (fields == null) {
            return BaseScaffold(
              appBar: CoworkAppBar.detail(title: _title),
              body: const Center(child: CoworkLoadingPane()),
            );
          }
          return _NoteEditForm(
            note: state.note,
            fields: fields,
            templateName: state.templateName,
            templateMissing: state.templateMissing,
            pickFile: pickFile,
          );
        },
      ),
    );
  }
}

/// 편집 폼. 컨트롤러·포커스 등 화면 상태를 들고, 저장은 [NoteEditBloc]에 위임한다.
class _NoteEditForm extends StatefulWidget {
  const _NoteEditForm({
    required this.note,
    required this.fields,
    required this.templateName,
    required this.templateMissing,
    required this.pickFile,
  });

  final Note note;
  final List<NoteSectionField> fields;
  final String? templateName;
  final bool templateMissing;
  final NoteFilePicker pickFile;

  @override
  State<_NoteEditForm> createState() => _NoteEditFormState();
}

class _NoteEditFormState extends State<_NoteEditForm> {
  late final _title = TextEditingController(text: widget.note.title);

  /// 섹션 제목 → 입력 컨트롤러. 처음 값은 회의록 본문이다.
  late final _controllers = {
    for (final field in widget.fields)
      field.title: TextEditingController(
        text: widget.note.sections[field.title] ?? '',
      ),
  };

  late final _focusNodes = {
    for (final field in widget.fields) field.title: FocusNode(),
  };

  /// 툴바 삽입 대상: 마지막으로 포커스됐던 섹션과 그때의 선택 영역.
  ///
  /// 툴바 버튼을 누르면 입력창이 blur 되면서 `controller.selection` 이 무효화되므로,
  /// 포커스가 살아 있는 동안 유효한 선택을 캐시해 둔다. 기본값은 맨 위 섹션이다.
  TextEditingController? _active;
  FocusNode? _activeFocus;
  TextSelection _activeSelection = const TextSelection.collapsed(offset: 0);

  @override
  void initState() {
    super.initState();
    for (final field in widget.fields) {
      _bind(_controllers[field.title]!, _focusNodes[field.title]!);
    }
    if (widget.fields.firstOrNull case final first?) {
      _active = _controllers[first.title];
      _activeFocus = _focusNodes[first.title];
    }
  }

  void _bind(TextEditingController controller, FocusNode focus) {
    void cache() {
      if (!focus.hasFocus) return;
      _active = controller;
      _activeFocus = focus;
      if (controller.selection.isValid) _activeSelection = controller.selection;
    }

    focus.addListener(cache);
    controller.addListener(cache);
  }

  @override
  void dispose() {
    _title.dispose();
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    for (final focus in _focusNodes.values) {
      focus.dispose();
    }
    super.dispose();
  }

  /// 툴바 버튼: 마지막으로 포커스된 섹션에 마크다운 서식을 삽입한다.
  void _applyMarkdown(MarkdownAction action) {
    final controller = _active;
    if (controller == null) return;
    final selection = _activeSelection.isValid
        ? _activeSelection
        : TextSelection.collapsed(offset: controller.text.length);
    final result = applyMarkdown(controller.text, selection, action);
    controller.value = TextEditingValue(
      text: result.text,
      selection: result.selection,
    );
    _activeSelection = result.selection;
    // 포커스가 풀려 있으면 편집을 이어갈 수 있도록 되돌린다.
    _activeFocus?.requestFocus();
  }

  void _save() {
    final title = _title.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('제목을 입력해 주세요.')));
      return;
    }
    context.read<NoteEditBloc>().add(
      NoteEditSaved(
        title: title,
        sections: {
          for (final field in widget.fields)
            field.title: _controllers[field.title]!.text.trim(),
        },
      ),
    );
  }

  /// 툴바 클립 버튼: 파일을 하나 골라 바로 올린다.
  Future<void> _attach() async {
    final UploadFile? file;
    try {
      file = await widget.pickFile();
    } catch (e, s) {
      // 선택 창이 열리지 않았거나 고른 파일을 읽지 못했다. 올리기 전이라 Bloc 에
      // 넘길 일이 없어 여기서 알린다.
      Logger.e('첨부할 파일 고르기 실패', tag: 'Notes', error: e, stackTrace: s);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('파일을 열지 못했어요.')));
      return;
    }
    if (file == null || !mounted) return;
    context.read<NoteEditBloc>().add(NoteEditAttachmentAdded(file));
  }

  @override
  Widget build(BuildContext context) {
    return BaseScaffold(
      appBar: CoworkAppBar.detail(
        title: NoteEditView._title,
        actions: [CoworkButton(label: '저장', onPressed: _save)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s6,
          AppSpacing.s20,
          AppSpacing.s24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _title,
              style: AppFont.titleM.copyWith(
                height: 1.32,
                color: AppColors.darkOnSurface,
              ),
              cursorColor: AppColors.red400,
              maxLines: null,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '제목을 입력하세요',
                hintStyle: TextStyle(color: AppColors.neutral500),
              ),
            ),
            const SizedBox(height: AppSpacing.s14),
            _MetaLine(
              author: widget.note.author,
              templateName: widget.templateName ?? '회의록',
            ),
            const SizedBox(height: AppSpacing.s14),
            const Divider(height: 1, thickness: 1, color: AppColors.neutral700),
            const SizedBox(height: AppSpacing.s14),
            if (widget.templateMissing) ...[
              const _Notice('템플릿을 불러오지 못해 저장된 섹션만 보여요.'),
              const SizedBox(height: AppSpacing.s14),
            ],
            if (widget.fields.isEmpty)
              const _Notice('이 템플릿에는 섹션이 없어요. 템플릿 관리에서 섹션을 추가해 주세요.'),
            for (final (index, field) in widget.fields.indexed) ...[
              if (index > 0) const SizedBox(height: AppSpacing.s20),
              _EditSection(
                field: field,
                controller: _controllers[field.title]!,
                focusNode: _focusNodes[field.title]!,
              ),
            ],
            const _AttachmentList(),
          ],
        ),
      ),
      bottomNavigationBar: _EditorToolbar(
        onAction: _applyMarkdown,
        onAttach: _attach,
      ),
    );
  }
}

/// 작성자 아바타 + `이름 · 날짜 · 템플릿 이름` (읽기 전용).
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.author, required this.templateName});

  final NoteAuthor author;
  final String templateName;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.blue500,
            shape: BoxShape.circle,
          ),
          child: Text(
            author.initial,
            style: AppFont.labelXs.copyWith(
              fontSize: 9,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Expanded(
          child: Text(
            '${author.name}  ·  ${author.date}  ·  $templateName',
            style: AppFont.subtextS.copyWith(color: AppColors.neutral300),
          ),
        ),
      ],
    );
  }
}

/// 섹션 위에 띄우는 안내 한 줄.
class _Notice extends StatelessWidget {
  const _Notice(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: AppFont.subtextS.copyWith(color: AppColors.neutral400),
    );
  }
}

/// 빨간 accent bar + 라벨 + 섹션 형식에 맞는 입력창으로 이뤄진 편집 섹션.
///
/// 날짜 형식도 글자로 저장되므로 직접 적을 수 있게 두고, 달력 버튼으로 고르면 칸을
/// 채운다. 서버 기본 템플릿의 `일시 / 장소` 처럼 날짜 뒤에 장소를 붙여 쓰는 섹션이
/// 있어서 선택 창만으로는 막지 않는다.
class _EditSection extends StatelessWidget {
  const _EditSection({
    required this.field,
    required this.controller,
    required this.focusNode,
  });

  final NoteSectionField field;
  final TextEditingController controller;
  final FocusNode focusNode;

  bool get _isDate =>
      field.type == NoteSectionType.date ||
      field.type == NoteSectionType.dateTime;

  String get _hintText {
    if (field.placeholder.isNotEmpty) return field.placeholder;
    return switch (field.type) {
      NoteSectionType.userList => '이름을 쉼표로 구분해 적어 주세요',
      NoteSectionType.date => '예: 2026-11-03',
      NoteSectionType.dateTime => '예: 2026-11-03 14:00',
      NoteSectionType.text || NoteSectionType.markdown => '내용을 입력하세요',
    };
  }

  /// 달력(과 시계)에서 고른 값으로 칸을 채운다.
  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (date == null || !context.mounted) return;
    var value =
        '${date.year}-${_twoDigits(date.month)}-${_twoDigits(date.day)}';
    if (field.type == NoteSectionType.dateTime) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
      );
      if (time == null) return;
      value = '$value ${_twoDigits(time.hour)}:${_twoDigits(time.minute)}';
    }
    controller.text = value;
  }

  static String _twoDigits(int value) => value.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final input = TextField(
      controller: controller,
      focusNode: focusNode,
      // 긴 텍스트만 여러 줄. 나머지는 한 줄로 받는다.
      maxLines: field.type == NoteSectionType.markdown ? null : 1,
      cursorColor: AppColors.red400,
      style: AppFont.subtextM.copyWith(
        fontSize: 15,
        height: 1.45,
        color: AppColors.darkOnSurface,
      ),
      decoration: InputDecoration(
        isDense: true,
        border: InputBorder.none,
        hintText: _hintText,
        hintStyle: AppFont.subtextM.copyWith(
          fontSize: 15,
          color: AppColors.neutral500,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(
          field.title,
          tags: [
            if (field.isRequired) const _SectionTag('필수', AppColors.red400),
            if (field.extra)
              const _SectionTag('템플릿에 없는 섹션', AppColors.neutral400),
          ],
        ),
        const SizedBox(height: AppSpacing.s8),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.s10),
          child: _isDate
              ? Row(
                  children: [
                    Expanded(child: input),
                    CoworkIconButton(
                      icon: Icons.calendar_today_outlined,
                      size: CoworkIconButtonSize.small,
                      variant: CoworkIconButtonVariant.ghost,
                      color: CoworkIconButtonColor.neutral,
                      semanticLabel: '날짜 고르기',
                      onPressed: () => _pick(context),
                    ),
                  ],
                )
              : input,
        ),
      ],
    );
  }
}

/// 빨간 accent bar + 섹션 라벨. 라벨 뒤에 [tags] 를 잇는다.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {this.tags = const []});

  final String title;
  final List<Widget> tags;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.red400,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.s8),
        Flexible(
          child: Text(
            title,
            style: AppFont.labelXs.copyWith(
              fontWeight: AppFont.semiBold,
              color: AppColors.darkOnSurface,
            ),
          ),
        ),
        ...tags,
      ],
    );
  }
}

/// 붙인 파일과 올리는 중인 파일. 둘 다 없으면 아무것도 그리지 않는다.
///
/// 폼은 입력값을 지키려고 템플릿을 읽을 때만 다시 그리므로, 첨부 목록은 여기서
/// 따로 상태를 듣는다.
class _AttachmentList extends StatelessWidget {
  const _AttachmentList();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NoteEditBloc, NoteEditState>(
      buildWhen: (previous, current) =>
          previous.note.attachments != current.note.attachments ||
          previous.uploads != current.uploads,
      builder: (context, state) {
        final attachments = state.note.attachments;
        if (attachments.isEmpty && state.uploads.isEmpty) {
          return const SizedBox.shrink();
        }
        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.s8,
            children: [
              const _SectionLabel('첨부파일'),
              for (final attachment in attachments)
                Row(
                  children: [
                    Expanded(child: NoteAttachmentCard(attachment: attachment)),
                    CoworkIconButton(
                      icon: Icons.close,
                      size: CoworkIconButtonSize.small,
                      variant: CoworkIconButtonVariant.ghost,
                      color: CoworkIconButtonColor.neutral,
                      semanticLabel: '${attachment.name} 빼기',
                      onPressed: () => context.read<NoteEditBloc>().add(
                        NoteEditAttachmentRemoved(attachment),
                      ),
                    ),
                  ],
                ),
              for (final upload in state.uploads)
                CoworkFileUploadProgress(
                  filename: upload.name,
                  progress: upload.progress,
                ),
            ],
          ),
        );
      },
    );
  }
}

/// 섹션 제목 옆의 작은 표시. (필수, 템플릿에 없는 섹션)
class _SectionTag extends StatelessWidget {
  const _SectionTag(this.label, this.color);

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.s6),
      child: Text(
        label,
        style: AppFont.subtextS.copyWith(
          fontSize: 11,
          height: null,
          fontWeight: AppFont.semiBold,
          color: color,
        ),
      ),
    );
  }
}

/// 하단 서식 툴바. Figma `Toolbar`(neutral 배경 + 상단 보더) 스타일.
///
/// 서식 버튼은 포커스된 섹션 입력창에 마크다운을 삽입하고, 클립 버튼은 파일을 붙인다.
class _EditorToolbar extends StatelessWidget {
  const _EditorToolbar({required this.onAction, required this.onAttach});

  final void Function(MarkdownAction) onAction;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.neutral800,
      child: SafeArea(
        top: false,
        child: Container(
          height: 54,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: AppColors.neutral700, width: 1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ToolbarButton(
                label: 'H',
                onTap: () => onAction(MarkdownAction.heading),
              ),
              _ToolbarButton(
                label: 'B',
                onTap: () => onAction(MarkdownAction.bold),
              ),
              _ToolbarButton(
                icon: Icons.format_list_bulleted,
                onTap: () => onAction(MarkdownAction.bullet),
              ),
              _ToolbarButton(
                icon: Icons.check_box_outlined,
                onTap: () => onAction(MarkdownAction.checkbox),
              ),
              _ToolbarButton(
                label: '@',
                onTap: () => onAction(MarkdownAction.mention),
              ),
              _ToolbarButton(icon: Icons.attach_file, onTap: onAttach),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolbarButton extends StatelessWidget {
  const _ToolbarButton({this.label, this.icon, required this.onTap})
    : assert(label != null || icon != null);

  final String? label;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.r8),
      child: SizedBox(
        width: 40,
        height: 36,
        child: Center(
          child: icon != null
              ? Icon(icon, size: 18, color: AppColors.neutral300)
              : Text(
                  label!,
                  style: AppFont.labelS.copyWith(
                    fontWeight: AppFont.semiBold,
                    color: AppColors.neutral300,
                  ),
                ),
        ),
      ),
    );
  }
}

/// 툴바가 삽입할 수 있는 마크다운 서식 종류.
enum MarkdownAction { bold, heading, bullet, checkbox, mention }

/// 포커스된 텍스트에 마크다운 서식을 적용한 결과(새 텍스트 + 커서 위치)를 돌려준다.
///
/// 위젯 없이 테스트할 수 있는 순수 함수다.
({String text, TextSelection selection}) applyMarkdown(
  String text,
  TextSelection selection,
  MarkdownAction action,
) {
  // 유효하지 않은 선택(-1)은 문서 끝 커서로 취급한다.
  final start = selection.start < 0 ? text.length : selection.start;
  final end = selection.end < 0 ? start : selection.end;

  switch (action) {
    case MarkdownAction.bold:
      if (start == end) {
        final next = '${text.substring(0, start)}****${text.substring(start)}';
        return (
          text: next,
          selection: TextSelection.collapsed(offset: start + 2),
        );
      }
      final selected = text.substring(start, end);
      final next =
          '${text.substring(0, start)}**$selected**${text.substring(end)}';
      return (text: next, selection: TextSelection.collapsed(offset: end + 4));
    case MarkdownAction.mention:
      final next = '${text.substring(0, start)}@${text.substring(end)}';
      return (
        text: next,
        selection: TextSelection.collapsed(offset: start + 1),
      );
    case MarkdownAction.heading:
      return _prefixLine(text, start, '# ');
    case MarkdownAction.bullet:
      return _prefixLine(text, start, '- ');
    case MarkdownAction.checkbox:
      return _prefixLine(text, start, '- [ ] ');
  }
}

/// [offset]이 놓인 줄의 맨 앞에 [prefix]를 삽입한다.
({String text, TextSelection selection}) _prefixLine(
  String text,
  int offset,
  String prefix,
) {
  final searchFrom = offset - 1;
  final newlineIndex = searchFrom < 0 ? -1 : text.lastIndexOf('\n', searchFrom);
  final lineStart = newlineIndex + 1;
  final next =
      '${text.substring(0, lineStart)}$prefix${text.substring(lineStart)}';
  return (
    text: next,
    selection: TextSelection.collapsed(offset: offset + prefix.length),
  );
}
