import 'dart:convert';

/// Server-Sent Events 이벤트 하나. [event] 가 없던 이벤트는 `message` 다.
typedef SseEvent = ({String event, String data});

/// `text/event-stream` 바이트를 이벤트로 나눈다.
///
/// 빈 줄이 이벤트 끝이고, `:` 로 시작하는 줄(keepalive 등)은 주석이라 버린다.
/// `data:` 가 여러 줄이면 줄바꿈으로 잇는다. `data` 가 없는 이벤트는 내보내지 않는다.
Stream<SseEvent> parseSse(Stream<List<int>> bytes) async* {
  var event = 'message';
  final data = <String>[];

  // dio 가 주는 스트림은 실제로 Stream<Uint8List> 라 transform 에 utf8.decoder 를
  // 넘기면 타입이 맞지 않는다. bind 는 List<int> 스트림이면 받는다.
  await for (final line in const LineSplitter().bind(
    utf8.decoder.bind(bytes),
  )) {
    if (line.isEmpty) {
      if (data.isNotEmpty) yield (event: event, data: data.join('\n'));
      event = 'message';
      data.clear();
      continue;
    }
    if (line.startsWith(':')) continue;

    final colon = line.indexOf(':');
    final field = colon == -1 ? line : line.substring(0, colon);
    var value = colon == -1 ? '' : line.substring(colon + 1);
    if (value.startsWith(' ')) value = value.substring(1);

    switch (field) {
      case 'event':
        event = value;
      case 'data':
        data.add(value);
    }
  }
}
