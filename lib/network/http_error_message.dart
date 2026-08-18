import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// dio 실패를 사용자에게 보여줄 문구로 바꾼다.
///
/// 응답이 있으면 서버가 거절한 것(4xx/5xx)이라 상태 코드와 서버 사유를 살리고,
/// 없으면 연결 자체가 안 된 것이라 코드를 붙일 게 없다.
///
/// 저장소마다 이 분기를 다시 쓰지 않도록 네트워크 공통 모듈에 둔다.
String dioErrorMessage(DioException e) {
  final failed = e.response;
  if (failed == null) return '네트워크에 연결할 수 없습니다.';
  return httpErrorMessage(
    failed.statusCode ?? 0,
    errorMessageOf(failed.data?.toString() ?? ''),
  );
}

/// DataGSM(`error_description`)과 게이트웨이(`message`) 양쪽 오류 형식을 읽는다.
@visibleForTesting
String? errorMessageOf(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is Map) {
      final message = decoded['error_description'] ?? decoded['message'];
      if (message is String && message.isNotEmpty) return message;
    }
  } catch (_) {
    // 오류 본문이 JSON 이 아니면 호출부의 기본 메시지를 쓴다.
  }
  return null;
}

/// HTTP 상태 코드를 사용자에게 그대로 보여줄 수 있는 문구로 바꾼다.
///
/// `(404) 페이지를 찾을 수 없습니다.` 처럼 코드를 앞에 붙여 문의 시 원인을 특정할 수
/// 있게 한다. [detail] 이 있으면(서버가 내려준 사유) 기본 문구 대신 그것을 쓴다.
String httpErrorMessage(int statusCode, [String? detail]) =>
    '($statusCode) ${detail ?? _reasons[statusCode] ?? _fallbackOf(statusCode)}';

String _fallbackOf(int statusCode) =>
    statusCode >= 500 ? '서버에 문제가 발생했습니다.' : '요청을 처리하지 못했습니다.';

const _reasons = {
  400: '요청이 올바르지 않습니다.',
  401: '로그인이 필요합니다.',
  403: '권한이 없습니다.',
  404: '페이지를 찾을 수 없습니다.',
  408: '요청 시간이 초과되었습니다.',
  429: '요청이 너무 많습니다. 잠시 후 다시 시도해 주세요.',
  500: '서버에 문제가 발생했습니다.',
  502: '서버에 연결할 수 없습니다.',
  503: '서비스를 잠시 사용할 수 없습니다.',
};
