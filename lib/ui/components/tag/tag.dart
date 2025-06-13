import 'package:flutter/material.dart';

class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.text,
    this.color = Colors.black,
    this.backgroundColor = Colors.white,
    this.borderColor = Colors.grey,
    this.showDeleteIcon = false,
    this.deleteIcon = const Icon(Icons.close, size: 13),
    this.deleteIconColor,
    this.textStyle,
    this.onDeleted,
  });

  final String text;
  final Color color;
  final Color backgroundColor;
  final Color borderColor;
  final bool showDeleteIcon;
  final Widget deleteIcon;
  final Color? deleteIconColor;
  final TextStyle? textStyle;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    const defaultTextStyle = TextStyle(
      fontSize: 12,
      height: 1.5,
    );

    final finalTextStyle = defaultTextStyle.copyWith(
      color: color,
      fontSize: textStyle?.fontSize ?? 12,
      fontWeight: textStyle?.fontWeight,
      letterSpacing: textStyle?.letterSpacing,
      height: textStyle?.height ?? 1.5,
      decoration: textStyle?.decoration,
      decorationColor: textStyle?.decorationColor,
      decorationStyle: textStyle?.decorationStyle,
      decorationThickness: textStyle?.decorationThickness,
      fontFamily: textStyle?.fontFamily,
      fontStyle: textStyle?.fontStyle,
      shadows: textStyle?.shadows,
      background: textStyle?.background,
      foreground: textStyle?.foreground,
    );

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: borderColor,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: finalTextStyle,
          ),
          if (showDeleteIcon) ...[
            const SizedBox(width: 4),
            GestureDetector(
              onTap: onDeleted,
              child: deleteIcon is Icon 
                ? Icon(
                    (deleteIcon as Icon).icon,
                    size: (deleteIcon as Icon).size,
                    color: deleteIconColor ?? color,
                  )
                : deleteIcon,
            ),
          ],
        ],
      ),
    );
  }
}
