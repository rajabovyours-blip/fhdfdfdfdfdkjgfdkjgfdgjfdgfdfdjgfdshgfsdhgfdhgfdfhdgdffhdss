import 'package:flutter/material.dart';

import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.height = 44.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isSecondary ? context.colors.surface : context.colors.primary,
          foregroundColor:
              isSecondary ? context.colors.textHigh : context.colors.onPrimary,
          disabledBackgroundColor: isSecondary
              ? context.colors.surface.withValues(alpha: 0.5)
              : context.colors.primary.withValues(alpha: 0.5),
          side: isSecondary ? BorderSide(color: context.colors.outline) : null,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: isLoading
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: isSecondary
                      ? context.colors.textHigh
                      : context.colors.onPrimary,
                ),
              )
            : Text(
                text,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
