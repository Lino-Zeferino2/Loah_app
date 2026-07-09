import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Top bar used across every screen: hamburger + "Loah" wordmark on the
/// left, screen-specific actions (bell, avatar, filter...) on the right.
class LoahAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget> actions;

  const LoahAppBar({
    super.key,
    this.title = 'Loah',
    this.actions = const [],
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return AppBar(
      titleSpacing: 16,
       automaticallyImplyLeading: false, 
      title: Row(
        children: [
          IconButton(
            icon: Icon(Icons.menu_rounded, color: colors.accentBlue),
            onPressed: () => Scaffold.of(context).openDrawer(),
            tooltip: 'Abrir menu',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [...actions, const SizedBox(width: 8)],
    );
  }
}

/// Small circular avatar placeholder used in the app bar.
class LoahAvatar extends StatelessWidget {
  final double radius;
  const LoahAvatar({super.key, this.radius = 16});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.cardBackgroundAlt,
      child: Icon(Icons.person, size: radius, color: context.textSecondary),
    );
  }
}
