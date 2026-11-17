import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 회의록을 지울지 묻는다. 지우기로 하면 true, 취소하거나 바깥을 눌러 닫으면 false.
///
/// 목록에서 밀어 지울 때와 상세 화면의 삭제 버튼이 같이 쓴다.
Future<bool> confirmDeleteNote(BuildContext context) async =>
    await CoworkDialog.show(
      context,
      title: '회의록을 삭제할까요?',
      message: '삭제한 회의록은 되돌릴 수 없어요.',
      confirmLabel: '삭제',
      cancelLabel: '취소',
      confirmColor: CoworkButtonColor.danger,
    ) ??
    false;
