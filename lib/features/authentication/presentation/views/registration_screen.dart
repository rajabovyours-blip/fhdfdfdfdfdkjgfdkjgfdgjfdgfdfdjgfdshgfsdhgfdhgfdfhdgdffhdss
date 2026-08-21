import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/authentication/presentation/widgets/auth_language_selector.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  final String? redirect;

  const RegistrationScreen({
    super.key,
    this.redirect,
  });

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _phoneController = TextEditingController();

  Future<void> _processRegistration() async {
    final name = _nameController.text.trim();
    final surname = _surnameController.text.trim();
    final phoneBody = _phoneController.text.replaceAll(' ', '');

    if (name.isEmpty || surname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.fillAllFields), // Need to add to l10n
          backgroundColor: context.colors.danger,
        ),
      );
      return;
    }

    if (phoneBody.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.invalidPhone),
          backgroundColor: context.colors.danger,
        ),
      );
      return;
    }
    final phone = '+998$phoneBody';

    // First check if phone exists (defensive check)
    final exists = await ref.read(authProvider.notifier).checkPhone(phone);
    if (!mounted) return;
    
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.accountExists), // Need to add to l10n
          backgroundColor: context.colors.danger,
        ),
      );
      return;
    }

    // Save registration data temporarily
    ref.read(authProvider.notifier).saveRegistrationData(name, surname);

    // Request OTP
    final success = await ref.read(authProvider.notifier).requestOtp(phone);
    if (success && mounted) {
      String route = AppRoutes.otp;
      if (widget.redirect != null) {
        route += '?redirect=${Uri.encodeComponent(widget.redirect!)}';
      }
      await context.push(route, extra: phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      next.maybeWhen(
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: context.colors.danger,
            ),
          );
        },
        orElse: () {},
      );
    });

    final authState = ref.watch(authProvider);
    final isLoading = authState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with Language Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: Icon(Icons.arrow_back_ios, color: context.colors.textHigh),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        Image.asset(
                          'assets/images/milliy_metr_logo_transparent.png',
                          height: 36,
                          errorBuilder: (context, error, stackTrace) => Text(
                            'MILLIY METR',
                            style: TextStyle(
                              color: context.colors.textHigh,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                        const AuthLanguageSelector(),
                      ],
                    ),
                    
                    SizedBox(height: isKeyboardOpen ? 24 : constraints.maxHeight * 0.05),

                    // Titles
                    Text(
                      context.l10n.register,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textHigh,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.registrationSubtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.colors.textMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    SizedBox(height: isKeyboardOpen ? 24 : constraints.maxHeight * 0.05),

                    // Name Input
                    _buildLabel(context.l10n.name),
                    _buildTextField(_nameController, context.l10n.nameHint, TextInputType.name, key: const Key('register_name_field')),
                    const SizedBox(height: 16),

                    // Surname Input
                    _buildLabel(context.l10n.surname),
                    _buildTextField(_surnameController, context.l10n.surnameHint, TextInputType.name, key: const Key('register_surname_field')),
                    const SizedBox(height: 16),

                    // Phone Input Label
                    _buildLabel(context.l10n.phoneNumber),
                    
                    // Phone Input Field
                    Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        border: Border.all(color: context.colors.outline),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              '🇺🇿 +998',
                              style: TextStyle(
                                color: context.colors.textHigh,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 24,
                            color: context.colors.outline,
                          ),
                          Expanded(
                            child: TextFormField(
                              key: const Key('register_phone_field'),
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                color: context.colors.textHigh,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                              decoration: InputDecoration(
                                hintText: '90 123 45 67',
                                hintStyle: TextStyle(
                                  color: context.colors.textMedium,
                                  letterSpacing: 1.0,
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Primary Action Button
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        key: const Key('register_submit_button'),
                        onPressed: isLoading ? null : _processRegistration,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.onPrimary,
                          disabledBackgroundColor:
                              context.colors.primary.withValues(alpha: 0.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: context.colors.onPrimary,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                context.l10n.sendOtp,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    
                    if (!isKeyboardOpen) ...[
                      SizedBox(height: constraints.maxHeight * 0.05),
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            context.pop();
                          },
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                color: context.colors.textMedium,
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text: '${context.l10n.alreadyHaveAccount} ',
                                ),
                                TextSpan(
                                  text: context.l10n.loginAction,
                                  style: TextStyle(
                                    color: context.colors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ] else const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: context.colors.textMedium,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, TextInputType type, {Key? key}) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.colors.outline),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextFormField(
        key: key,
        controller: controller,
        keyboardType: type,
        style: TextStyle(
          color: context.colors.textHigh,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: context.colors.textMedium,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
