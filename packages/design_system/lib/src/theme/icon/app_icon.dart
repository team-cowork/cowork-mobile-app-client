import 'package:flutter/material.dart';
import '../../constants/app_size.dart';

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
  );
}
