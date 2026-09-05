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
        if (width < 700) {
          return child;
        }
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth ?? 1280),
            child: child,
          ),
        );
      },
    );
  }
}
