import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/shared/widgets/app_snackbar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:milliy_metr/core/utils/image_utils.dart';

class PersonalInformationScreen extends ConsumerStatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  ConsumerState<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState
    extends ConsumerState<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _avatarUrl;
  String? _localAvatarPath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      authState.whenOrNull(
        authenticated: (user) {
          _nameController.text = user.fullName ?? '';
          _emailController.text = user.email ?? '';
          _phoneController.text = user.phone ?? '';
          _avatarUrl = user.avatarUrl;
        },
      );
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return '?';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          l10n.personalInfo,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : () async {
              if (_isEditing) {
                if (_formKey.currentState!.validate()) {
                  setState(() => _isSaving = true);
                  final error = await ref.read(authProvider.notifier).updateProfile(
                    _nameController.text,
                    _emailController.text,
                    _phoneController.text,
                    _avatarUrl ?? '',
                  );
                  setState(() => _isSaving = false);
                  if (!context.mounted) return;
                  
                  if (error == null) {
                    setState(() => _isEditing = false);
                    AppSnackBar.showSuccess(context, l10n.profileUpdated);
                  } else {
                    AppSnackBar.showError(context, error);
                  }
                }
              } else {
                setState(() => _isEditing = true);
              }
            },
            child: _isSaving
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: context.colors.primary),
                  )
                : Text(
                    _isEditing ? l10n.save : l10n.editProfile,
                    style: TextStyle(
                      color: context.colors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (!_isEditing) return;
                    
                    await showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return SafeArea(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                  leading: const Icon(Icons.photo_library),
                                  title: Text(context.l10n.pickFromGallery),
                                  onTap: () async {
                                    Navigator.of(context).pop();
                                    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                                    if (image != null) unawaited(_uploadImage(image));
                                  },),
                              ListTile(
                                leading: const Icon(Icons.photo_camera),
                                title: Text(context.l10n.takePhoto),
                                onTap: () async {
                                  Navigator.of(context).pop();
                                  final XFile? image = await _picker.pickImage(source: ImageSource.camera);
                                  if (image != null) unawaited(_uploadImage(image));
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: context.colors.surfaceVariant,
                        backgroundImage: _localAvatarPath != null
                            ? FileImage(File(_localAvatarPath!))
                            : (_avatarUrl != null && _avatarUrl!.isNotEmpty
                                ? NetworkImage(ImageUtils.getFullImageUrl(_avatarUrl!)) as ImageProvider
                                : null),
                        child: _localAvatarPath == null && (_avatarUrl == null || _avatarUrl!.isEmpty)
                            ? Text(
                                _getInitials(_nameController.text),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: context.colors.primary,
                                ),
                              )
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 18,
                              color: context.colors.background,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Full Name
              _buildField(
                label: l10n.fullName,
                controller: _nameController,
                icon: Icons.person_outline,
                enabled: _isEditing,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return l10n.enterFullName;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone (read-only)
              _buildField(
                label: l10n.phone,
                controller: _phoneController,
                icon: Icons.phone_outlined,
                enabled: _isEditing,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),

              // Email
              _buildField(
                label: l10n.email,
                controller: _emailController,
                icon: Icons.email_outlined,
                enabled: _isEditing,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val != null && val.isNotEmpty && !val.contains('@')) {
                    return l10n.enterEmail;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: context.colors.textHigh, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: context.colors.textMedium),
        prefixIcon: Icon(icon, color: context.colors.textMedium),
        filled: true,
        fillColor:
            enabled ? context.colors.surface : context.colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.colors.primary, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              BorderSide(color: context.colors.outline.withValues(alpha: 0.5)),
        ),
      ),
    );
  }

  Future<void> _uploadImage(XFile image) async {
    setState(() {
      _localAvatarPath = image.path;
      _isSaving = true;
    });
    try {
      final dio = ref.read(dioProvider);
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: image.name),
      });

      final response = await dio.post('/upload/image', data: formData);
      if (response.statusCode == 200) {
        setState(() {
          _avatarUrl = response.data['data']['url'];
        });
      }
    } catch (e) {
      setState(() {
        _localAvatarPath = null;
      });
      if (mounted) {
        AppSnackBar.showError(context, context.l10n.errorOccurred);
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }
}
