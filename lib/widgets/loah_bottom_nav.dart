import 'package:flutter/material.dart';
import '../core/l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';

class LoahBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const LoahBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (icon: Icons.grid_view_rounded, key: 'nav_dashboard'),
    (icon: Icons.flag_outlined, key: 'nav_metas'),
    (icon: Icons.check_circle_outline, key: 'nav_tarefas'),
    (icon: Icons.account_balance_wallet_outlined, key: 'nav_financas'),
    (icon: Icons.contacts_outlined, key: 'drawer_contatos'),
  ];


  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.cardBackground,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final selected = index == currentIndex;
              final color = selected
                  ? colors.accentBlue
                  : Theme.of(context).iconTheme.color;
              return Expanded(
                child: InkWell(
                  onTap: () => onTap(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(item.icon, color: color, size: 22),
                      const SizedBox(height: 2),
                      Text(
                        AppLocales.of(context).translate(item.key),
                        style: TextStyle(
                          fontSize: 10,
                          color: color,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
