import 'package:flutter/material.dart';

/// Minimal app bar for pushed sub-screens that aren't one of the four
/// main tabs (so no drawer/menu icon — just a back arrow + title).
/// Used by screens like Patrimônio and Contas that are one level deep
/// from Finanças, not a top-level destination of their own.
class LoahAppBarSimple extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const LoahAppBarSimple({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) => AppBar(title: Text(title));
}