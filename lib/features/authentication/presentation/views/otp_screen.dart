import 'dart:async';
import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:milliy_metr/core/providers/auth_provider.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:milliy_metr/features/authentication/presentation/widgets/auth_language_selector.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String phone;
  final String? redirect;
  const OtpScreen({super.key, required this.phone, this.redirect});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final _otpController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _timer;
  int _secondsRemaining = 60;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() => _secondsRemaining = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _verify() {
    if (_otpController.text.length == 6) {
      ref.read(authProvider.notifier).verifyOtp(
            widget.phone,
            _otpController.text,
          );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.invalidOtpLength), // Will add to l10n
          backgroundColor: context.colors.danger,
        ),
      );
    }
  }

  Future<void> _resendOtp() async {
    if (_secondsRemaining == 0) {
      final success =
          await ref.read(authProvider.notifier).requestOtp(widget.phone);
      if (success && mounted) {
        _startTimer();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.newOtpSent),
            backgroundColor: context.colors.success,
          ),
        );
      }
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

    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
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
                          onPressed: () => Navigator.of(context).pop(),
                          icon: Icon(Icons.arrow_back_ios, color: context.colors.textHigh),
                          padding: EdgeInsets.zero,
                          alignment: Alignment.centerLeft,
                        ),
                        const AuthLanguageSelector(),
                      ],
                    ),
                    
                    SizedBox(height: isKeyboardOpen ? 16 : constraints.maxHeight * 0.05),
                    
                    Center(
                      child: Image.asset(
                        'assets/images/milliy_metr_logo_clean.png',
                        height: 80,
                        errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.lock_outline,
                          size: 80,
                          color: context.colors.textHigh,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    Text(
                      l10n.verifyCodeTitle,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: context.colors.textHigh,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.otpSentMessage(widget.phone),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: context.colors.textDisabled,
                        height: 1.4,
                      ),
                    ),
                    
                    SizedBox(height: isKeyboardOpen ? 24 : constraints.maxHeight * 0.05),

                    // Custom OTP Input
                    GestureDetector(
                      onTap: () => _focusNode.requestFocus(),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // The invisible text field that takes input
                          Opacity(
                            opacity: 0.0,
                            child: TextField(
                              key: const Key('otp_field'),
                              controller: _otpController,
                              focusNode: _focusNode,
                              keyboardType: TextInputType.number,
                              maxLength: 6,
                              autofocus: true,
                              onChanged: (val) {
                                setState(() {}); // Trigger rebuild to update UI
                                if (val.length == 6) {
                                  _verify();
                                }
                              },
                            ),
                          ),
                          // The visible UI boxes
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(6, (index) {
                              final isFocused = _focusNode.hasFocus &&
                                  ((_otpController.text.length == index) ||
                                      (_otpController.text.length == 6 && index == 5));
                              
                              final hasText = index < _otpController.text.length;
                              final char = hasText ? _otpController.text[index] : '';

                              return Flexible(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                                  height: 56,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: context.colors.surface,
                                    border: Border.all(
                                      color: isFocused
                                          ? context.colors.primary
                                          : context.colors.outline,
                                      width: isFocused ? 2 : 1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    char,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: context.colors.textHigh,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Verify Button
                    SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        key: const Key('otp_submit_button'),
                        onPressed: isLoading ? null : _verify,
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
                                l10n.verify,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Resend Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${l10n.didNotReceiveCode} ',
                          style: TextStyle(
                            color: context.colors.textDisabled,
                            fontSize: 14,
                          ),
                        ),
                        GestureDetector(
                          onTap: _secondsRemaining == 0 && !isLoading
                              ? _resendOtp
                              : null,
                          child: Text(
                            _secondsRemaining > 0
                                ? l10n.resendCodeIn(_secondsRemaining)
                                : l10n.resendCode,
                            style: TextStyle(
                              color: _secondsRemaining == 0
                                  ? context.colors.primary
                                  : context.colors.textMedium,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!isKeyboardOpen) SizedBox(height: constraints.maxHeight * 0.1),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
