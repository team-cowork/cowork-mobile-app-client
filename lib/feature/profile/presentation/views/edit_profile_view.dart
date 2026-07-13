import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/edit_profile.dart';
import '../viewModels/edit_profile_bloc.dart';

/// 프로필 편집 화면. 설정 화면의 `프로필 편집` 항목에서 진입한다.
///
/// Figma `App / Edit Profile (프로필 편집)` 스펙에 맞춘 다크 전용 레이아웃.
class EditProfileView extends StatelessWidget {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc()..add(const EditProfileRequested()),
      child: Scaffold(
        backgroundColor: AppColors.neutral850,
        body: SafeArea(
          child: Column(
            children: [
              const _EditProfileHeader(),
              Expanded(
                child: BlocBuilder<EditProfileBloc, EditProfileState>(
                  builder: (context, state) {
                    return switch (state) {
                      EditProfileFailure() => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.s16),
                          child: CoworkErrorState(
                            title: '프로필을 불러오지 못했어요',
                            description: '잠시 후 다시 시도해 주세요.',
                            retryLabel: '다시 시도',
                            onRetry: () => context
                                .read<EditProfileBloc>()
                                .add(const EditProfileRequested()),
                          ),
                        ),
                      ),
                      EditProfileSuccess(:final profile) => _EditProfileForm(
                        profile: profile,
                      ),
                      _ => const Center(child: CircularProgressIndicator()),
                    };
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 취소 / 제목 / 저장으로 구성된 상단 헤더.
class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s16,
        AppSpacing.s6,
        AppSpacing.s16,
        AppSpacing.s12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _HeaderAction(
            label: '취소',
            color: AppColors.neutral300,
            onTap: () => Navigator.of(context).maybePop(),
          ),
          Text(
            '프로필 편집',
            style: AppFont.labelS.copyWith(
              fontSize: 16,
              color: AppColors.darkOnSurface,
            ),
          ),
          _HeaderAction(
            label: '저장',
            color: AppColors.red400,
            onTap: () {
              // TODO: 프로필 저장 API 연동. 현재는 화면만 닫는다.
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.label,
    required this.color,
    required this.onTap,
  });

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Text(
        label,
        style: AppFont.labelS.copyWith(color: color),
      ),
    );
  }
}

/// 아바타 + 입력 필드로 구성된 편집 폼.
///
/// 로드된 [EditProfile] 초기값으로 컨트롤러를 채우기 위해 StatefulWidget으로 둔다.
class _EditProfileForm extends StatefulWidget {
  const _EditProfileForm({required this.profile});

  final EditProfile profile;

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  late final TextEditingController _name;
  late final TextEditingController _username;
  late final TextEditingController _statusMessage;
  late final TextEditingController _bio;

  @override
  void initState() {
    super.initState();
    final p = widget.profile;
    _name = TextEditingController(text: p.name);
    _username = TextEditingController(text: p.username);
    _statusMessage = TextEditingController(text: p.statusMessage);
    _bio = TextEditingController(text: p.bio);
  }

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _statusMessage.dispose();
    _bio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.s20,
        AppSpacing.s8,
        AppSpacing.s20,
        AppSpacing.s20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: AppSpacing.s20,
        children: [
          _AvatarEditor(initial: widget.profile.avatarInitial),
          _LabeledField(
            label: '이름',
            controller: _name,
            hintText: '표시할 이름을 입력하세요',
          ),
          _LabeledField(
            label: '사용자명',
            controller: _username,
          ),
          _LabeledField(
            label: '상태 메시지',
            controller: _statusMessage,
            hintText: '예: PR 리뷰 환영 🙌',
          ),
          _LabeledField(
            label: '자기소개',
            controller: _bio,
            minLines: 3,
            maxLines: 5,
          ),
        ],
      ),
    );
  }
}

/// 아바타(이니셜) + 카메라 뱃지 + `사진 변경` 링크.
class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({required this.initial});

  final String initial;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              children: [
                Container(
                  width: 96,
                  height: 96,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.blue500,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: AppFont.displayM.copyWith(
                      fontSize: 40,
                      color: AppColors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.red400,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.neutral850,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.photo_camera,
                      size: 15,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.s10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              // TODO: 사진 변경(이미지 피커) 로직 추가.
            },
            child: Text(
              '사진 변경',
              style: AppFont.subtextM.copyWith(
                fontWeight: AppFont.semiBold,
                color: AppColors.red400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 라벨 + 다크 입력 필드. Figma 필드 스펙(neutral800 배경, neutral700 테두리).
class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hintText,
    this.minLines,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String? hintText;
  final int? minLines;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppFont.subtextS.copyWith(
            fontWeight: AppFont.semiBold,
            color: AppColors.neutral300,
          ),
        ),
        const SizedBox(height: AppSpacing.s8),
        TextField(
          controller: controller,
          minLines: minLines,
          maxLines: maxLines,
          cursorColor: AppColors.red400,
          style: AppFont.subtextL.copyWith(color: AppColors.darkOnSurface),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.neutral800,
            hintText: hintText,
            hintStyle: AppFont.subtextL.copyWith(color: AppColors.neutral300),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.s14,
              vertical: 13,
            ),
            border: _border(AppColors.neutral700),
            enabledBorder: _border(AppColors.neutral700),
            focusedBorder: _border(AppColors.neutral600),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(AppRadius.r12),
    borderSide: BorderSide(color: color),
  );
}
