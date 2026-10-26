import 'package:cowork_app/feature/profile/data/model/requests/update_status_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('상태 메시지를 지울 때는 message 를 빼지 않고 null 로 보낸다', () {
    // 서버는 보낸 필드만 반영하므로, 빼면 예전 메시지가 남는다.
    expect(const UpdateStatusRequest(customStatus: 'ONLINE').toJson(), {
      'custom_status': 'ONLINE',
      'message': null,
    });
  });
}
