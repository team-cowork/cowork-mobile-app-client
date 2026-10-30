import 'package:dio/dio.dart';

import '../../../../core/network/dio_client.dart';
import '../../../auth/data/auth_repository.dart';
import '../../domain/note_template.dart';
import '../model/requests/meeting_note_template_request.dart';
import '../model/requests/template_section_request.dart';
import '../model/responses/meeting_note_template_response.dart';
import '../model/responses/template_section_response.dart';

/// channel 서비스의 회의록 템플릿(`/channels/{channelId}/meeting-note-templates`) 저장소.
///
/// 템플릿은 채널에 속한다. 서버는 `MEETING_NOTE` 채널을 만들 때 기본 템플릿 하나를
/// 같이 만들고, 그 뒤로는 채널 멤버가 늘리고 고친다. 고치는 요청은 모두 바로
/// 서버에 반영되고, 바뀐 템플릿·섹션을 돌려준다.
class NoteTemplateRepository {
  NoteTemplateRepository(AuthRepository auth)
    : this.withDio(createAuthedDio(ApiService.channel, auth));

  NoteTemplateRepository.withDio(this._dio);

  final Dio _dio;

  /// 채널의 템플릿을 섹션까지 담아 서버 순서대로.
  Future<List<NoteTemplate>> fetchTemplates(int channelId) async => [
    for (final json in unwrapListPayload(
      (await _dio.get<String>(_templates(channelId))).data ?? '',
    ))
      MeetingNoteTemplateResponse.fromJson(json).toTemplate(),
  ];

  /// 템플릿 하나. 회의록 편집 화면이 섹션 형식을 읽을 때 쓴다.
  Future<NoteTemplate> fetchTemplate(int channelId, int templateId) async =>
      _templateOf(await _dio.get<String>(_template(channelId, templateId)));

  /// 섹션 없는 템플릿을 만든다. 서버는 새 템플릿을 기본으로 두지 않는다.
  Future<NoteTemplate> createTemplate(int channelId, String name) async =>
      _templateOf(
        await _dio.post<String>(
          _templates(channelId),
          data: MeetingNoteTemplateRequest(name: name).toJson(),
        ),
      );

  Future<NoteTemplate> renameTemplate(
    NoteTemplate template,
    String name,
  ) async => _templateOf(
    await _dio.patch<String>(
      _template(template.channelId, template.id),
      data: MeetingNoteTemplateRequest(name: name).toJson(),
    ),
  );

  /// 채널의 기본 템플릿으로 둔다. 이전 기본 템플릿은 서버가 해제한다.
  Future<NoteTemplate> setDefault(NoteTemplate template) async => _templateOf(
    await _dio.patch<String>(
      '${_template(template.channelId, template.id)}/activate',
    ),
  );

  /// 템플릿을 지운다. 기본 템플릿은 서버가 400 으로 거절한다.
  Future<void> deleteTemplate(NoteTemplate template) =>
      _dio.delete<String>(_template(template.channelId, template.id));

  Future<NoteTemplateSection> addSection(
    NoteTemplate template,
    TemplateSectionRequest request,
  ) async => _sectionOf(
    await _dio.post<String>(
      '${_template(template.channelId, template.id)}/sections',
      data: request.toJson(),
    ),
  );

  Future<NoteTemplateSection> updateSection(
    NoteTemplate template,
    int sectionId,
    TemplateSectionRequest request,
  ) async => _sectionOf(
    await _dio.patch<String>(
      '${_template(template.channelId, template.id)}/sections/$sectionId',
      data: request.toJson(),
    ),
  );

  Future<void> deleteSection(NoteTemplate template, int sectionId) =>
      _dio.delete<String>(
        '${_template(template.channelId, template.id)}/sections/$sectionId',
      );

  static String _templates(int channelId) =>
      '/channels/$channelId/meeting-note-templates';

  static String _template(int channelId, int templateId) =>
      '${_templates(channelId)}/$templateId';

  static NoteTemplate _templateOf(Response<String> response) =>
      MeetingNoteTemplateResponse.fromJson(
        unwrapPayload(response.data ?? ''),
      ).toTemplate();

  static NoteTemplateSection _sectionOf(Response<String> response) =>
      TemplateSectionResponse.fromJson(
        unwrapPayload(response.data ?? ''),
      ).toSection();
}
