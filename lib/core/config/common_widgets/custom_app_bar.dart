import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool? centerTitle;
  final Color? backgroundColor;
  final double? elevation;
  final IconThemeData? iconTheme;
  final TextStyle? titleTextStyle;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle,
    this.backgroundColor,
    this.elevation,
    this.iconTheme,
    this.titleTextStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = Colors.red;

    return AppBar(
      
      title: Text(
        title,
        style: titleTextStyle ?? theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimary,
          fontSize: 17
        ),
      ),
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: bg,
      elevation: elevation ?? 2.0,
      iconTheme: iconTheme ?? IconThemeData(color: Colors.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}



