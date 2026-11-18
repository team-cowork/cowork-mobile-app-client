import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../shared/widgets/create_sheet.dart';

/// [AddTeamSheet] 에서 고른 방법.
enum AddTeamChoice { create, join }

/// 팀 목록 끝 `+` 를 눌렀을 때 팀을 만들지, 초대 코드로 들어갈지 고르는 시트.
///
/// 팀 진입점을 `+` 하나로 두려고 두 방법을 여기서 가른다. 고른 뒤 열 시트는 부른
/// 쪽이 정한다. 만든 팀과 참여한 팀을 홈에 반영하는 방법이 달라서다.
class AddTeamSheet extends StatelessWidget {
  const AddTeamSheet({super.key});

  /// 시트를 띄우고 고른 방법을 돌려준다. 고르지 않고 닫으면 null.
  static Future<AddTeamChoice?> show(BuildContext context) =>
      CreateSheet.show<AddTeamChoice>(context, (_) => const AddTeamSheet());

  @override
  Widget build(BuildContext context) {
    void choose(AddTeamChoice choice) => Navigator.of(context).pop(choice);

    return CreateSheet(
      title: '팀 추가',
      children: [
        CoworkOptionCard(
          label: '새 팀 만들기',
          description: '팀을 만들고 함께할 사람을 초대해요',
          icon: Icons.group_add_outlined,
          onTap: () => choose(AddTeamChoice.create),
        ),
        CoworkOptionCard(
          label: '초대 코드로 참여',
          description: '받은 초대 코드로 팀에 들어가요',
          icon: Icons.vpn_key_outlined,
          onTap: () => choose(AddTeamChoice.join),
        ),
      ],
    );
  }
}
