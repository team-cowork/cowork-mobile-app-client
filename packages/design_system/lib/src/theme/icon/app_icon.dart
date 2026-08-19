import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 앱 아이콘 모음
class AppIcon {
  AppIcon._();

  // 공통
  static const IconData home = Icons.home_outlined;
  static const IconData back = Icons.arrow_back_ios_new;
  static const IconData close = Icons.close;
  static const IconData search = Icons.search;
  static const IconData settings = Icons.settings_outlined;


  // 네비게이션
  static const IconData navHome = Icons.home_outlined;
  static const IconData navProfile = Icons.person_outline;
  static const IconData navNotification = Icons.notifications_outlined;
  static const IconData navChannel = Icons.forum_outlined;
  static const IconData navIssue = Icons.view_kanban_outlined;
  static const IconData navNote = Icons.description_outlined;

  static Widget hashChannel({double size = AppSize.iconSmall}) => Image.asset(
    'assets/images/hash_channel.png',
    package: 'cowork_design_system',
    width: size,
    height: size,
    fit: BoxFit.contain,
    color: AppColors.neutral300,
  );

  static Widget dropDown({double size = AppSize.iconSmall}) => SvgPicture.asset(
    'assets/images/chevron-down.svg',
    package: 'cowork_design_system',
    width: size,
    height: size,
    fit: BoxFit.contain,
  );

  static Widget bell({double size = AppSize.iconSmall}) => SvgPicture.asset(
    'assets/images/bell.svg',
    package: 'cowork_design_system',
    width: size,
    height: size,
    fit: BoxFit.contain,
  );

  static Widget chat({double size = AppSize.iconSmall}) => Image.asset(
    'assets/images/chat.png',
    package: 'cowork_design_system',
    width: size,
    height: size,
    fit: BoxFit.contain,
  );

  static Widget speaker({double size = AppSize.iconSmall}) => Image.asset(
    'assets/images/speaker.png',
    package: 'cowork_design_system',
    width: size,
    height: size,
    fit: BoxFit.contain,
  );

  static Widget channelChat({double size = AppSize.iconXSmall}) => Image.asset(
    'assets/images/channel_chat.png',
    package: 'cowork_design_system',
    width: size,
    height: size,
    fit: BoxFit.contain,
  );

  static Widget webhook({double size = AppSize.iconSmall}) => Image.asset(
    'assets/images/webhook.png',
    package: 'cowork_design_system',
    width: size,
    height: size,
    fit: BoxFit.contain,
  );

  static Widget plus({double size = AppSize.iconSmall}) => Image.asset(
    'assets/images/plus.png',
    package: 'cowork_design_system',
    width: size,
    height: size,
    fit: BoxFit.contain,
  );

  static Widget taskAssigned({double size = AppSize.iconSmall}) => SvgPicture.asset(
    'assets/images/task_assigned.svg',
    package: 'cowork_design_system',
    width: size,
    height: size,
    fit: BoxFit.contain,
  );

  static Widget gitPush({double size = AppSize.iconSmall}) => SvgPicture.asset(
    'assets/images/git_push.svg',
    package: 'cowork_design_system',
    width: size,
    height: size,
    fit: BoxFit.contain,
  );

}
