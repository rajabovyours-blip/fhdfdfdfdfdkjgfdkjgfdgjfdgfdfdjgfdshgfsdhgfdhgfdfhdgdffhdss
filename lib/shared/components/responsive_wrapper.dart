import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 480.0,
  });

  @override
  Widget build(BuildContext context) {
    // Only apply the layout constraints on Web or Desktop platforms
    if (!kIsWeb && (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.android)) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > maxWidth) {
          return ColoredBox(
            color: const Color(0xFFF3F4F6), // subtle gray background for the outer area
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: ClipRect(
                  child: child,
                ),
              ),
            ),
          );
        }
        return child;
      },
    );
  }
}
