import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';

class CustomStarRating extends StatefulWidget {
  final int initialRating;
  final ValueChanged<int>? onRatingChanged;
  final double itemSize;
  final bool ignoreGestures;

  const CustomStarRating({
    super.key,
    this.initialRating = 0,
    this.onRatingChanged,
    this.itemSize = 40.0,
    this.ignoreGestures = false,
  });

  @override
  State<CustomStarRating> createState() => _CustomStarRatingState();
}

class _CustomStarRatingState extends State<CustomStarRating> {
  late int _currentRating;

  @override
  void initState() {
    super.initState();
    _currentRating = widget.initialRating;
  }

  @override
  void didUpdateWidget(CustomStarRating oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRating != oldWidget.initialRating) {
      _currentRating = widget.initialRating;
    }
  }

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= _currentRating) {
      icon = Icon(
        Icons.star_border,
        color: context.colors.textMedium,
        size: widget.itemSize,
      );
    } else {
      icon = Icon(
        Icons.star,
        color: context.colors.warning,
        size: widget.itemSize,
      );
    }

    if (widget.ignoreGestures) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2.0),
        child: icon,
      );
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentRating = index + 1;
        });
        if (widget.onRatingChanged != null) {
          widget.onRatingChanged!(_currentRating);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: icon,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) => buildStar(context, index)),
    );
  }
}
