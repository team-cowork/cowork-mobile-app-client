import 'dart:io';

import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../domain/edit_profile.dart';
import '../viewModels/edit_profile_bloc.dart';

/// 프로필 편집 화면. 설정 화면의 `프로필 편집` 항목에서 진입한다.
///
/// Figma `App / Edit Profile (프로필 편집)` 스펙에 맞춘 다크 전용 레이아웃.
class EditProfileView extends StatefulWidget {
  const EditProfileView({super.key});

  @override
  State<EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _name = TextEditingController();
  final _username = TextEditingController();
  final _statusMessage = TextEditingController();
  final _bio = TextEditingController();

  /// 로컬에서 새로 선택한 사진. 선택 전에는 프로필 아바타를 그대로 보여준다.
  File? _pickedImage;
  String _avatarUrl = '';
  String _avatarInitial = '';

  /// 로드된 값으로 컨트롤러를 한 번만 채우기 위한 플래그.
  bool _seeded = false;

  @override
  void dispose() {
    _name.dispose();
    _username.dispose();
    _statusMessage.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _seed(EditProfile p) {
    if (_seeded) return;
    _seeded = true;
    _name.text = p.name;
    _username.text = p.username;
    _statusMessage.text = p.statusMessage;
    _bio.text = p.bio;
    _avatarUrl = p.avatarUrl;
    _avatarInitial = p.avatarInitial;
    if (p.localAvatarPath != null) {
      _pickedImage = File(p.localAvatarPath!);
    }
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    setState(() => _pickedImage = File(picked.path));
  }

  void _save(BuildContext context) {
    context.read<EditProfileBloc>().add(
      EditProfileSubmitted(
        name: _name.text.trim(),
        username: _username.text.trim(),
        statusMessage: _statusMessage.text.trim(),
        bio: _bio.text.trim(),
        localAvatarPath: _pickedImage?.path,
      ),
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EditProfileBloc()..add(const EditProfileRequested()),
      child: Builder(
        builder: (context) => Scaffold(
          backgroundColor: AppColors.neutral850,
          body: SafeArea(
            child: Column(
              children: [
                _EditProfileHeader(
                  onCancel: () => Navigator.of(context).maybePop(),
                  onSave: () => _save(context),
                ),
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
                        EditProfileSuccess(:final profile) => _buildForm(
                          profile,
                        ),
                        _ => const Center(child: CoworkLoadingPane()),
                      };
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(EditProfile profile) {
    _seed(profile);
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
          _AvatarEditor(
            avatarUrl: _avatarUrl,
            initial: _avatarInitial,
            pickedImage: _pickedImage,
            onChangePhoto: _pickImage,
          ),
          CoworkTextField(
            labelText: '이름',
            controller: _name,
            hintText: '표시할 이름을 입력하세요',
          ),
          CoworkTextField(labelText: '사용자명', controller: _username),
          CoworkTextField(
            labelText: '상태 메시지',
            controller: _statusMessage,
            hintText: '예: PR 리뷰 환영 🙌',
          ),
          CoworkTextArea(
            labelText: '자기소개',
            controller: _bio,
            minLines: 3,
          ),
        ],
      ),
    );
  }
}

/// 취소 / 제목 / 저장으로 구성된 상단 헤더.
class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader({required this.onCancel, required this.onSave});

  final VoidCallback onCancel;
  final VoidCallback onSave;

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
            onTap: onCancel,
          ),
          Text(
            '프로필 편집',
            style: AppFont.labelS.copyWith(
              fontSize: 16,
              color: AppColors.darkOnSurface,
            ),
          ),
          _HeaderAction(label: '저장', color: AppColors.red400, onTap: onSave),
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
      child: Text(label, style: AppFont.labelS.copyWith(color: color)),
    );
  }
}

/// 아바타(사진/이니셜) + 카메라 뱃지 + `사진 변경` 링크.
///
/// 표시 우선순위: 로컬에서 새로 고른 사진 > 프로필 아바타 URL > 이니셜 폴백.
class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({
    required this.avatarUrl,
    required this.initial,
    required this.pickedImage,
    required this.onChangePhoto,
  });

  final String avatarUrl;
  final String initial;
  final File? pickedImage;
  final VoidCallback onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onChangePhoto,
            child: SizedBox(
              width: 96,
              height: 96,
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    alignment: Alignment.center,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: AppColors.blue500,
                      shape: BoxShape.circle,
                    ),
                    child: _avatar(),
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
          ),
          const SizedBox(height: AppSpacing.s10),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onChangePhoto,
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

  Widget _avatar() {
    if (pickedImage != null) {
      return Image.file(pickedImage!, width: 96, height: 96, fit: BoxFit.cover);
    }
    if (avatarUrl.isNotEmpty) {
      return Image.network(
        avatarUrl,
        width: 96,
        height: 96,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialFallback(),
      );
    }
    return _initialFallback();
  }

  Widget _initialFallback() => Text(
    initial,
    style: AppFont.displayM.copyWith(fontSize: 40, color: AppColors.white),
  );
}
