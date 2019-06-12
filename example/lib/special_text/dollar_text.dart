import 'package:extended_text_library/extended_text_library.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'my_special_text_span_builder.dart';

class DollarText extends SpecialText {
  static const String flag = "\$";
  final int start;
  final BuilderType type;
  DollarText(TextStyle textStyle, SpecialTextGestureTapCallback onTap,
      {this.type, this.start})
      : super(flag, flag, textStyle, onTap: onTap);

  @override
  TextSpan finishText() {
    final String text = getContent();

    return SpecialTextSpan(
        text: text,
        actualText: toString(),
        start: start,

        ///caret can move into special text
        deleteAll: true,
        style: textStyle?.copyWith(color: Colors.orange),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            if (onTap != null) onTap(toString());
          });
  }
}

List<String> dollarList = <String>[
  "\$Dota2\$",
  "\$Dota2 Ti9\$",
  "\$CN dota best dota\$",
  "\$Flutter\$",
  "\$CN dev best dev\$",
  "\$UWP\$",
  "\$Nevermore\$",
  "\$FlutterCandies\$",
  "\$ExtendedImage\$",
  "\$ExtendedText\$",
];
