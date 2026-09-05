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
        // Desktop should use full width at the root level, 
        // constraints will be applied per-page or per-component.
        return child;
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