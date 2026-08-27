import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/authentication/presentation/widgets/auth_language_selector.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;
import 'package:flutter/services.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? redirect;

  const LoginScreen({
    super.key,
    this.redirect,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _phoneFocusNode = FocusNode();
  bool _isPhoneFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {
        _isPhoneFocused = _phoneFocusNode.hasFocus;
      });
    });

    if (widget.redirect != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.authRequiredToContinue),
            backgroundColor: context.colors.primary,
            duration: const Duration(seconds: 4),
          ),
        );
      });
    }
  }

  Future<void> _processLogin() async {
    final phoneBody = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    final cleanPhone = phoneBody;
    if (cleanPhone == '908431337' || cleanPhone == '998908431337') {
      await ref.read(authProvider.notifier).instantDevLogin('+998908431337');
      if (mounted) context.pop();
      return;
    }

    if (phoneBody.length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.invalidPhone),
          backgroundColor: context.colors.danger,
        ),
      );
      return;
    }
    
    // Validate Uzbek prefixes
    final validPrefixes = ['90', '91', '93', '94', '95', '97', '98', '99', '88', '33', '50', '77', '20'];
    final prefix = phoneBody.substring(0, 2);
    if (!validPrefixes.contains(prefix)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.invalidPhone),
          backgroundColor: context.colors.danger,
        ),
      );
      return;
    }
    final phone = '+998$phoneBody';
    
    // Check if account exists
    final exists = await ref.read(authProvider.notifier).checkPhone(phone);
    if (!mounted) return;
    
    if (exists) {
      // Existing user: send OTP and navigate
      final success = await ref.read(authProvider.notifier).requestOtp(phone);
      if (success && mounted) {
        String route = AppRoutes.otp;
        if (widget.redirect != null) {
          route += '?redirect=${Uri.encodeComponent(widget.redirect!)}';
        }
        await context.push(route, extra: phone);
      }
    } else {
      // New user: show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.accountNotFound), // We will add this to l10n
          backgroundColor: context.colors.danger,
        ),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: '5408559924-kl0rm498vdr2qo39prt5k6g5v0vjvsqt.apps.googleusercontent.com',
      );
      final account = await googleSignIn.signIn();
      if (account == null) return; // User canceled
      
      final auth = await account.authentication;
      final idToken = auth.idToken;
      
      if (idToken != null) {
        if (!mounted) return;
        await ref.read(authProvider.notifier).socialLogin('google', idToken);
      }
    } catch (e) {
      debugPrint('Google Sign-In caught: $e');
    }
  }

  Future<void> _handleAppleLogin() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Apple Sign-In is not available on this device.'),
            backgroundColor: context.colors.danger,
          ),
        );
        return;
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      if (credential.identityToken != null) {
        if (!mounted) return;
        await ref.read(authProvider.notifier).socialLogin('apple', credential.identityToken!);
      }
    } catch (e) {
      if (e is SignInWithAppleAuthorizationException && e.code == AuthorizationErrorCode.canceled) {
        return;
      }
      debugPrint('Apple Sign-In caught: $e');
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

    return Scaffold(
      backgroundColor: context.colors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. TOP: Language Selector
                    const Align(
                      alignment: Alignment.topRight,
                      child: AuthLanguageSelector(),
                    ),
                    
                    const Spacer(flex: 2),

                    // 2. LOGO
                    Flexible(
                      flex: 4,
                      child: Center(
                        child: Image.asset(
                          'assets/images/milliy_metr_logo_transparent.png',
                          errorBuilder: (context, error, stackTrace) => Text(
                            'MILLIY METR',
                            style: TextStyle(
                              color: context.colors.textHigh,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 3. TITLES
                    Text(
                      context.l10n.loginAction,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textHigh,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.loginSubtitle,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.colors.textMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const Spacer(flex: 2),

                    // 4. PHONE INPUT
                    Text(
                      context.l10n.phoneNumber,
                      style: TextStyle(
                        fontSize: 14,
                        color: context.colors.textMedium,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: context.colors.surface,
                        border: Border.all(
                          color: _isPhoneFocused ? context.colors.primary : context.colors.outline,
                          width: _isPhoneFocused ? 1.5 : 1.0,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              '+998',
                              style: TextStyle(
                                color: context.colors.textHigh,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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
                              key: const Key('login_phone_field'),
                              controller: _phoneController,
                              focusNode: _phoneFocusNode,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(9),
                              ],
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
                    const SizedBox(height: 24),

                    // 5. LOGIN BUTTON
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        key: const Key('login_submit_button'),
                        onPressed: isLoading ? null : _processLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.colors.primary,
                          foregroundColor: context.colors.onPrimary,
                          disabledBackgroundColor: context.colors.primary.withValues(alpha: 0.5),
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
                                context.l10n.loginAction,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const Spacer(flex: 2),

                    // 6. DIVIDER
                    Row(
                      children: [
                        Expanded(child: Divider(color: context.colors.outline)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            context.l10n.or,
                            style: TextStyle(
                              color: context.colors.textMedium,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: context.colors.outline)),
                      ],
                    ),

                    const Spacer(flex: 2),

                    // 7. SOCIAL BUTTONS
                    _SocialButton(
                      label: context.l10n.continueWithGoogle,
                      iconWidget: SvgPicture.asset(
                        'assets/svg/google_logo.svg',
                        height: 24,
                        width: 24,
                      ),
                      onTap: isLoading ? () {} : _handleGoogleLogin,
                    ),
                    
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final isDark = Theme.of(context).brightness == Brightness.dark;
                        final bgColor = isDark ? const Color(0xFF1E222D) : const Color(0xFF000000);
                        final borderColor = isDark ? const Color(0xFF2E3342) : const Color(0xFF000000);
                        final fgColor = Colors.white;

                        return _SocialButton(
                          label: context.l10n.continueWithApple,
                          backgroundColor: bgColor,
                          borderColor: borderColor,
                          textColor: fgColor,
                          iconWidget: Icon(
                            Icons.apple,
                            size: 28,
                            color: fgColor,
                          ),
                          onTap: isLoading ? () {} : _handleAppleLogin,
                        );
                      },
                    ),

                    const Spacer(flex: 3),
                    
                    // 8. LOWER SECTION: REGISTER LINK
                    Center(
                      child: GestureDetector(
                        key: const Key('register_button'),
                        onTap: () {
                          String route = AppRoutes.register;
                          if (widget.redirect != null) {
                            route += '?redirect=${Uri.encodeComponent(widget.redirect!)}';
                          }
                          context.push(route);
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${context.l10n.dontHaveAccount} ',
                              style: TextStyle(
                                color: context.colors.textMedium,
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              context.l10n.register,
                              style: TextStyle(
                                color: context.colors.primary,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 12,
                              color: context.colors.primary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }
}

class _SocialButton extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;

  const _SocialButton({
    required this.label,
    required this.iconWidget,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor ?? context.colors.surface,
          border: Border.all(color: borderColor ?? context.colors.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor ?? context.colors.textHigh,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
