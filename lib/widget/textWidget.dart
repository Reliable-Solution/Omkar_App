// Flutter
import 'package:flutter/material.dart';
//Packages

import '../theme/nativeTheme.dart';

class TextWiget extends StatelessWidget {
  final String? title;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  const TextWiget({
    @required this.title,
    this.style,
    this.textAlign,
    this.maxLines,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$title',
      style: style ?? Themes.dark.textTheme.displayLarge,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
