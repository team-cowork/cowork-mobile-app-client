import 'dart:io';

import 'package:dio/dio.dart';

import '../../../network/dio_client.dart';
import '../../auth/data/auth_repository.dart';
import 'profile_store.dart';
import 'user_request.dart';
import 'user_response.dart';

/// `/users/me` 를 다루는 저장소. 내 프로필 조회·수정과 프로필 사진을 맡는다.
///
/// 조회·수정·상태 변경이 모두 같은 사용자 표현을 돌려주므로 [UserResponse] 하나로
/// 받는다. 프로필 화면과 편집 화면이 같은 응답에서 서로 다른 필드를 쓰기 때문에,
/// 화면용 변환은 각 도메인 모델의 `fromMe` 팩토리가 맡는다.
class ProfileRepository {
  ProfileRepository(AuthRepository auth)
    : this.withDio(createAuthedDio(auth), createDio());

  ProfileRepository.withDio(this._dio, [Dio? uploader])
    : _uploader = uploader ?? _dio;

  final Dio _dio;

  /// 사진을 스토리지의 presigned URL 로 직접 올릴 때 쓰는 dio.
  ///
  /// [_dio] 를 쓰면 인터셉터가 Authorization 을 붙이는데, presigned 서명에 없는
  /// 헤더가 섞이면 스토리지가 요청을 거부한다. 그래서 인증 없는 dio 로 따로 보낸다.
  final Dio _uploader;

  /// 내 프로필 조회.
  Future<UserResponse> fetchMe() async =>
      _cache(await _get(_dio.get<String>('/users/me')));

  /// 내 프로필 수정. 서버가 갱신된 프로필을 그대로 돌려준다.
  ///
  /// 프로필 사진은 여기서 못 바꾼다. 업로드는 [uploadProfileImage] 가 맡는다.
  Future<UserResponse> updateMe(UpdateMeRequest request) async => _cache(
    await _get(_dio.patch<String>('/users/me', data: request.toJson())),
  );

  /// 상태 메시지 변경. `status` 는 필수라 서버가 들고 있던 값을 그대로 돌려보낸다.
  Future<UserResponse> updateStatus(UpdateStatusRequest request) async =>
      _cache(
        await _get(
          _dio.patch<String>('/users/me/status', data: request.toJson()),
        ),
      );

  /// 프로필 사진 업로드. presigned 발급 → 스토리지 PUT → confirm 3단계다.
  ///
  /// confirm 은 응답 본문이 없다. 새 사진 URL 은 뒤이어 부르는 조회·수정 응답에
  /// 실려 오므로 여기서 프로필을 다시 읽지 않는다.
  Future<void> uploadProfileImage(String path) async {
    final contentType = _imageContentType(path);
    final presigned = PresignedUploadResponse.fromJson(
      unwrapPayload(
        (await _dio.post<String>(
              '/users/me/profile-image/presigned',
              data: PresignedUploadRequest(contentType: contentType).toJson(),
            )).data ??
            '',
      ),
    );

    // Uint8List 는 dio 가 변환 없이 그대로 실어 보낸다. 갤러리에서 고른 사진 한
    // 장이라 통째로 읽어도 부담이 없다.
    await _uploader.put<void>(
      presigned.uploadUrl,
      data: await File(path).readAsBytes(),
      options: Options(contentType: contentType),
    );

    await _dio.post<String>(
      '/users/me/profile-image/confirm',
      data: ConfirmProfileImageRequest(objectKey: presigned.objectKey).toJson(),
    );
  }

  /// 프로필 사진 삭제. 이후 조회 응답의 `profile_image_url` 은 비어서 온다.
  Future<void> deleteProfileImage() =>
      _dio.delete<String>('/users/me/profile-image');

  /// 응답 본문에서 envelope 을 벗겨 [UserResponse] 로 옮긴다.
  static Future<UserResponse> _get(Future<Response<String>> request) async =>
      UserResponse.fromJson(unwrapPayload((await request).data ?? ''));

  /// presigned 발급과 업로드에 쓸 MIME 타입. 서명에 들어가므로 두 요청이 같은
  /// 값을 써야 한다. 확장자를 못 알아보면 jpeg 로 본다. 갤러리에서 오는 사진의
  /// 대부분이고, 서버가 거부하면 그때 확장자를 늘리면 된다.
  static String _imageContentType(String path) =>
      switch (path.split('.').last.toLowerCase()) {
        'png' => 'image/png',
        'gif' => 'image/gif',
        'webp' => 'image/webp',
        'heic' => 'image/heic',
        _ => 'image/jpeg',
      };

  /// 회의록 작성자(내 이름·사진·id)를 쓰는 [ProfileStore] 를 최신 응답으로 갱신한다.
  ///
  /// ponytail: 프로필 화면에 들어와야 갱신된다. 앱 시작 직후 회의록부터 쓰면
  /// 목 기본값이 남는다. 로그인 직후 한 번 부르는 걸로 올리려면 AuthGate 에서.
  UserResponse _cache(UserResponse me) {
    final name = me.name;
    if (name != null && name.isNotEmpty) {
      final store = ProfileStore.instance
        ..name = name
        ..avatarInitial = name.substring(0, 1)
        ..avatarUrl = me.profileImageUrl ?? '';
      final id = me.id;
      if (id != null) store.currentUserId = id;
    }
    return me;
  }
}
