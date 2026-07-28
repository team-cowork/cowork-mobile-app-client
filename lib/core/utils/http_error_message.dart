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
