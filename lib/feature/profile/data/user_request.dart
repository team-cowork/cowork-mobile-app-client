/// `PATCH /users/me` 요청 본문.
///
/// 서버는 보낸 필드만 반영한다. 지금 편집 화면이 다루는 세 가지만 담고,
/// `github_id`/`roles` 는 편집 수단이 생길 때 필드를 늘린다.
class UpdateMeRequest {
  const UpdateMeRequest({
    required this.name,
    required this.nickname,
    required this.description,
  });

  final String name;
  final String nickname;

  /// 자기소개.
  final String description;

  Map<String, dynamic> toJson() => {
    'name': name,
    'nickname': nickname,
    'description': description,
  };
}

/// `PATCH /users/me/status` 요청 본문.
///
/// [status] 는 필수라, 상태 메시지만 바꿀 때도 서버가 들고 있던 값을 그대로
/// 되돌려 보낸다. [message] 는 null 이면 상태 메시지를 지운다.
class UpdateStatusRequest {
  const UpdateStatusRequest({required this.status, this.message});

  final String status;
  final String? message;

  Map<String, dynamic> toJson() => {'status': status, 'message': message};
}

/// `POST /users/me/profile-image/presigned` 요청 본문.
///
/// [contentType] 은 presigned 서명에 들어가므로 실제 업로드 요청의
/// `Content-Type` 과 같아야 한다.
class PresignedUploadRequest {
  const PresignedUploadRequest({required this.contentType});

  final String contentType;

  Map<String, dynamic> toJson() => {'content_type': contentType};
}

/// `POST /users/me/profile-image/confirm` 요청 본문.
class ConfirmProfileImageRequest {
  const ConfirmProfileImageRequest({required this.objectKey});

  /// presigned 발급 때 받은 값.
  final String objectKey;

  Map<String, dynamic> toJson() => {'object_key': objectKey};
}
