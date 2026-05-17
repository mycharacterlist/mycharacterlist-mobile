import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget
    implements PreferredSizeWidget {

  final String title;

  final Color backgroundColor;

  final Widget? actionWidget;

  final Color backButtonColor;

  final Color titleColor;

  const CustomAppBar({
    super.key,

    required this.title,
    required this.titleColor,
    required this.backgroundColor,
    required this.backButtonColor,

    this.actionWidget,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor,

      centerTitle: true,

      title: Text(
        title,

        style:TextStyle(
          color: titleColor,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'JosefinSans',
        ),
      ),

      leading: IconButton(
        icon: Icon(
          Icons.arrow_back,
          color: backButtonColor,
        ),

        onPressed: () {
          Navigator.pop(context);
        },
      ),

      actions: [
        if (actionWidget != null)
          actionWidget!,
      ],
    );
  }

  @override
  Size get preferredSize =>
      const Size.fromHeight(kToolbarHeight);
}