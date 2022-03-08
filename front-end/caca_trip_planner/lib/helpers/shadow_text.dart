import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// This widget adds shadow to Texts in a different way than TextStyle. Source:
/// StackOverflow
class ShadowText extends StatelessWidget {
  ShadowText(this.data, {this.style}) : assert(data != null);

  final String data;
  final TextStyle? style;

  Widget build(BuildContext context) {
    return new ClipRect(
      child: new Stack(
        children: [
          new Positioned(
            top: 2.0,
            left: 2.0,
            child: new Text(
              data,
              style: style != null
                  ? style!.copyWith(color: Colors.black.withOpacity(0.5))
                  : null,
            ),
          ),
          new BackdropFilter(
            filter: new ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
            child: new Text(data, style: style),
          ),
        ],
      ),
    );
  }
}
