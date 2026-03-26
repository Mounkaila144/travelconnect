import 'dart:io';

import 'package:flutter/material.dart';
import 'package:travelconnect_app/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';

class AvatarPicker extends StatelessWidget {
  final String? currentAvatarUrl;
  final File? selectedImage;
  final bool isUploading;
  final ValueChanged<File> onImageSelected;

  const AvatarPicker({
    super.key,
    this.currentAvatarUrl,
    this.selectedImage,
    this.isUploading = false,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        GestureDetector(
          onTap: isUploading ? null : () => _showImageSourceDialog(context),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.surfaceWhite,
                    width: 3,
                  ),
                  boxShadow: AppShadows.subtle,
                ),
                child: CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.surfaceVariant,
                  backgroundImage: _getImage(),
                  child: _getPlaceholder(),
                ),
              ),
              if (isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black26,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ),
              if (!isUploading)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.surfaceWhite,
                        width: 2,
                      ),
                      boxShadow: AppShadows.subtle,
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(
          onPressed: isUploading ? null : () => _showImageSourceDialog(context),
          child: Text(l10n.avatar_changePhoto),
        ),
      ],
    );
  }

  ImageProvider? _getImage() {
    if (selectedImage != null) {
      return FileImage(selectedImage!);
    }
    if (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty) {
      return NetworkImage(currentAvatarUrl!);
    }
    return null;
  }

  Widget? _getPlaceholder() {
    if (selectedImage != null || (currentAvatarUrl != null && currentAvatarUrl!.isNotEmpty)) {
      return null;
    }
    return const Icon(Icons.person, size: 50, color: AppColors.textTertiary);
  }

  void _showImageSourceDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.avatar_gallery),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.avatar_camera),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      onImageSelected(File(pickedFile.path));
    }
  }
}
