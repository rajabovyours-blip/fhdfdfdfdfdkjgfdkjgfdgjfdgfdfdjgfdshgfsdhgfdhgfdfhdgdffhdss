import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;

  const ResponsiveWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Mobil ilova (Android/iOS) — hech narsa o'zgarmaydi, asl holida qoladi
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Telefon brauzerida (tor oyna) — hech narsa o'zgarmaydi
        if (width < 700) {
          return child;
        }

        // Kompyuter/planshet uchun ekran kengligining deyarli barchasini
        // (94%) egallaydi — endi "o'rtada tor ustuncha" bo'lib qolmaydi.
        // Faqat juda katta (ultra-wide) monitorlarda qator uzunligi
        // cheksiz cho'zilib ketmasligi uchun 1600px'da chegara qo'yiladi
        final double maxWidth = width >= 1600 ? 1600 : width * 0.94;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final outerColor = isDark ? const Color(0xFF010409) : const Color(0xFFF3F4F6);

        return ColoredBox(
          color: outerColor,
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

class ResponsivePageContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;

  const ResponsivePageContainer({
    super.key,
    required this.child,
    this.maxWidth = 1280,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final maxW = maxWidth ?? 1280.0;
        
        if (width <= maxW) {
          return child;
        }
        
        final padding = (width - maxW) / 2;
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: child,
        );
      },
    );
  }
}

double responsiveHorizontalPadding(BuildContext context, {double maxWidth = 1280, double defaultPadding = 16}) {
  final width = MediaQuery.sizeOf(context).width;
  if (width <= maxWidth) return defaultPadding;
  return (width - maxWidth) / 2 + defaultPadding;
}