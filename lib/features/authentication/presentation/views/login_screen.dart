import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/router/route_constants.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/authentication/presentation/widgets/auth_language_selector.dart';
import 'package:milliy_metr/shared/components/responsive_wrapper.dart';
import 'package:flutter/foundation.dart';

import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';
import 'package:milliy_metr/shared/widgets/app_snackbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Keep only digits
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 9) {
      digits = digits.substring(0, 9);
    }
    
    // Format as ## ### ## ##
    String formatted = '';
    for (int i = 0; i < digits.length; i++) {
      if (i == 2 || i == 5 || i == 7) {
        formatted += ' ';
      }
      formatted += digits[i];
    }
    
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

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

    if (widget.redirect != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppSnackBar.showSuccess(context, context.l10n.authRequiredToContinue);
      });
    }
  }

  Future<void> _processLogin() async {
    final phoneBody = _phoneController.text.replaceAll(RegExp(r'\D'), '');


    if (phoneBody.length != 9) {
      AppSnackBar.showError(context, context.l10n.invalidPhone);
      return;
    }
    
    // Validate Uzbek prefixes
    final validPrefixes = ['90', '91', '93', '94', '95', '97', '98', '99', '88', '33', '50', '77', '20'];
    final prefix = phoneBody.substring(0, 2);
    if (!validPrefixes.contains(prefix)) {
      AppSnackBar.showError(context, context.l10n.invalidPhone);
      return;
    }
    final phone = '+998$phoneBody';
    
    // Send OTP directly regardless of whether user exists
    final success = await ref.read(authProvider.notifier).requestOtp(phone);
    if (!mounted) return;
    
    if (success) {
      String route = AppRoutes.otp;
      if (widget.redirect != null) {
        route += '?redirect=${Uri.encodeComponent(widget.redirect!)}';
      }
      await context.push(route, extra: phone);
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? '433156009799-tia3qrtgo44tq5eaj9n7b03r4t7q6f5j.apps.googleusercontent.com' : null,
        serverClientId: kIsWeb ? null : '433156009799-tia3qrtgo44tq5eaj9n7b03r4t7q6f5j.apps.googleusercontent.com',
      );
      final account = await googleSignIn.signIn();
      if (account == null) return; // User canceled
      
      var auth = await account.authentication;
      var idToken = auth.idToken;
      
      // On Web (GIS), signIn() might not return idToken, so we use signInSilently
      if (kIsWeb && idToken == null) {
        final silentAccount = await googleSignIn.signInSilently();
        if (silentAccount != null) {
          auth = await silentAccount.authentication;
          idToken = auth.idToken;
        }
      }
      
      // Fallback: If idToken is still null, send accessToken. Our backend will handle it.
      final tokenToSend = idToken ?? auth.accessToken;
      
      if (tokenToSend != null) {
        if (!mounted) return;
        await ref.read(authProvider.notifier).socialLogin('google', tokenToSend);
      } else {
        if (!mounted) return;
        AppSnackBar.showError(context, 'Google Sign-In failed: Could not retrieve any token.');
      }
    } catch (e) {
      debugPrint('Google Sign-In caught: $e');
      if (mounted) {
        AppSnackBar.showError(context, '${context.l10n.googleSignInError}: $e');
      }
    }
  }

  Future<void> _handleAppleLogin() async {
    try {
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        if (!mounted) return;
        AppSnackBar.showError(context, 'Apple Sign-In is not available on this device.');
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
      if (mounted) {
        AppSnackBar.showError(context, context.l10n.appleSignInError);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      next.maybeWhen(
        error: (message) {
          AppSnackBar.showError(context, message);
        },
        authenticated: (_) {
          final redirect = widget.redirect;
          if (redirect != null && redirect.isNotEmpty) {
            context.go(redirect);
          } else {
            context.go(AppRoutes.home);
          }
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
      body: ResponsivePageContainer(
        maxWidth: 600,
        child: SafeArea(
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
              Focus(
                onFocusChange: (hasFocus) {
                  setState(() => _isPhoneFocused = hasFocus);
                },
                child: Container(
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
                          controller: _phoneController,
                          focusNode: _phoneFocusNode,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[\d\s]')),
                            _PhoneFormatter(),
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

              const Spacer(flex: 1),

              // 6. OR DIVIDER
              Row(
                children: [
                  Expanded(child: Divider(color: context.colors.outline, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      context.l10n.or,
                      style: TextStyle(
                        color: context.colors.textMedium,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: context.colors.outline, thickness: 1)),
                ],
              ),
              const SizedBox(height: 24),

              // 7. SOCIAL LOGIN BUTTONS (Platform specific)
              if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS)
                _SocialButton(
                  label: context.l10n.continueWithApple,
                  iconWidget: Icon(Icons.apple, color: context.colors.onPrimary, size: 24),
                  backgroundColor: Colors.black,
                  textColor: Colors.white,
                  borderColor: Colors.black,
                  onTap: _handleAppleLogin,
                )
              else
                _SocialButton(
                  label: context.l10n.continueWithGoogle,
                  iconWidget: FaIcon(
                    FontAwesomeIcons.google,
                    size: 24,
                    color: context.colors.textHigh,
                  ),
                  onTap: _handleGoogleLogin,
                ),

              const Spacer(flex: 2),
            ],
          ),
        ),
      )),
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
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: textColor ?? context.colors.textHigh,
                  fontSize: 15,
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
