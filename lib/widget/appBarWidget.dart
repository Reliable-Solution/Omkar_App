//flutter
import 'package:flutter/material.dart';

import '../constant/colorConst.dart';
//constants

class MyCustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double? height;

  final Widget? title;
  final Widget? leading;
  final List<Widget>? action;
  final double? elevation;
  final double? titleSpacing;
  final String? text;
  final double? appbarPadding;
  final double? actionPadding;
  final double? textSize;

  const MyCustomAppBar({
    super.key,
    @required this.height,
    this.title,
    this.text,
    this.appbarPadding,
    this.titleSpacing,
    this.elevation,
    this.action,
    this.leading,
    this.actionPadding,
    this.textSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: appbarPadding ?? 0.0,
            bottom: appbarPadding ?? 0.0,
          ),
          child: AppBar(
            iconTheme: IconThemeData(color: Colors.white),
            actionsPadding: EdgeInsets.all(actionPadding ?? 0),
            leading: leading,
            backgroundColor: COLOR.appBaseColor,
            elevation: elevation,
            titleSpacing: titleSpacing,
            centerTitle: false,
            title:
                title ??
                Text(text ?? "", style: TextStyle(fontSize: textSize ?? 18)),
            actions: action,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height ?? 56.0);
}
