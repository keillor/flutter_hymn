import 'package:flutter/material.dart';

class CircleText extends StatelessWidget {
  final String text;
  final double size;
  final TextStyle? textStyle;
  final Color? backgroundColor;

  const CircleText({
    super.key,
    required this.text,
    this.size = 48.0,
    this.textStyle,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final TextStyle baseStyle =
        textStyle ?? Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16);
    final Color fg = baseStyle.color ?? Theme.of(context).colorScheme.onPrimary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: baseStyle.copyWith(color: fg),
        ),
      ),
    );
  }
}