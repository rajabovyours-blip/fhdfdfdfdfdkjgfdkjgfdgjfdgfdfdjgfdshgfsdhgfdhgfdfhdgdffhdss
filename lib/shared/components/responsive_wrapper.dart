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

        // Kompyuter/planshet uchun ekran kengligining o'rtacha qismini egallaydi
        // Shunda tugmalar va elementlar haddan tashqari cho'zilib ketmaydi.
        // Maksimal kenglik 1200px (Desktop standarti)
        final double maxWidth = width > 1200 ? 1200 : width;

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final outerColor = isDark ? const Color(0xFF010409) : const Color(0xFFF3F4F6);

        if (width <= 1200) {
          return child;
        }

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
