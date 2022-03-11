import 'package:flutter/material.dart';

/// This wrapper does not work!!!
class FlippablePage extends StatelessWidget {
  final VoidCallback? onFlip;
  final Widget child;
  final Widget? flipButtonStyle;
  final Rect? flipButtonPosition;

  /// [WARNING] The helper widget does not work yet! Fix it before using it!
  const FlippablePage({
    required this.child,
    this.flipButtonStyle,
    this.flipButtonPosition,
    this.onFlip,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return child;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        child,
        if (flipButtonStyle != null && flipButtonPosition != null)
          Positioned.fromRect(
            rect: flipButtonPosition!,
            child: IconButton(
              icon: flipButtonStyle!,
              onPressed: onFlip,
            ),
          )
      ],
    );
  }
}
