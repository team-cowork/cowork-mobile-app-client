// 채널 화면과 생성 시트를 로그인 없이 띄워 보는 하네스.
//
//   fvm flutter run -t tool/preview_channel.dart -d <에뮬레이터>
//
// 채널 목록은 `ChatHomeStore` 인메모리 목 데이터라 서버 스텁이 필요 없다.
// 워크스페이스 이름을 누르면 새 프로젝트 시트, `+` 를 누르면 새 채널 시트가 뜬다.
//
// lib/ 밖이라 앱 번들에는 안 들어가지만 analyze 대상이라, 화면 API 가 바뀌면
// 여기서 먼저 깨진다.
import 'package:cowork_app/feature/chat/presentation/views/chat_view.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

void main() => runApp(
  MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: AppTheme.dark(),
    home: const ChatView(),
  ),
);
