import 'package:flutter/material.dart';

enum LineDirection {
  horizontal,
  vertical,
}

class DividerLine extends StatelessWidget {
  final LineDirection direction;
  final double thickness;
  final double? length;
  final double? widthMinus;   // 新增：屏幕宽度减多少
  final double? heightMinus;  // 新增：屏幕高度减多少
  final Color color;
  final EdgeInsetsGeometry margin;


  const DividerLine({
    super.key,
    this.direction = LineDirection.horizontal,
    this.thickness = 1.0,
    this.length,
    this.widthMinus,
    this.heightMinus,
    this.color = const Color(0xFFDDDDDD),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    final isHorizontal = direction == LineDirection.horizontal;
    double? finalLength;

    if (isHorizontal && widthMinus != null) {
      finalLength = MediaQuery.of(context).size.width - widthMinus!;
    } else if (!isHorizontal && heightMinus != null) {
      finalLength = MediaQuery.of(context).size.height - heightMinus!;
    } else {
      finalLength = length;
    }

    final line = Container(
      width: isHorizontal ? (finalLength ?? double.infinity) : thickness,
      height: isHorizontal ? thickness : (finalLength ?? double.infinity),
      color: color,
    );

    return Padding(
      padding: margin,
      child: line,
    );
  }
}
