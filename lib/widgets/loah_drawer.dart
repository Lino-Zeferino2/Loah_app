import 'package:flutter/material.dart';
import 'package:loah_app/core/services/auth_service.dart';
import 'package:loah_app/screens/auth/login_screen.dart';
import 'package:loah_app/widgets/loah_app_bar.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../screens/support/about_loah_screen.dart';
import '../screens/support/help_center_screen.dart';
import 'drawer_nav_item.dart';
import 'theme_toggle_switch.dart';

/// Loah's side drawer ("Menu Lateral"): profile header, main navigation
/// (Dashboard, Metas, Tarefas, Finanças, Contatos), a settings section
/// (theme + language) and a logout action.
///
/// [currentIndex] highlights the active nav item; [onNavigate] is
/// called with the tapped item's index (0..4) and should close the
/// drawer + switch the visible screen.
class LoahDrawer extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;
  final String userName;
  final String userEmail;

  const LoahDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
    this.userName = 'Arthur',
    this.userEmail = 'arthur@loah.app',
  });

  static const _navItems = [
    (icon: Icons.grid_view_rounded, label: 'Dashboard'),
    (icon: Icons.track_changes_outlined, label: 'Metas'),
    (icon: Icons.check_circle_outline, label: 'Tarefas'),
    (icon: Icons.account_balance_wallet_outlined, label: 'Finanças'),
    (icon: Icons.contacts_outlined, label: 'Contatos'),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final themeController = LoahThemeController.of(context);
    final isDark = themeController.themeMode == ThemeMode.dark;

    return Drawer(
      backgroundColor: colors.cardBackground,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // --- Profile header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    const LoahAvatar(radius: 26),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          Text(
                            userEmail,
                            style: TextStyle(
                              color: colors.accentBlue,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // --- Main navigation ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: [
                    for (var i = 0; i < _navItems.length; i++)
                      DrawerNavItem(
                        icon: _navItems[i].icon,
                        label: _navItems[i].label,
                        selected: i == currentIndex,
                        onTap: () {
                          Navigator.of(context).pop(); // close drawer
                          onNavigate(i);
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // --- Settings + Support ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Divider(color: colors.border),
                    const SizedBox(height: 8),
                    Text(
                      'CONFIGURAÇÕES',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: colors.cardBackgroundAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isDark
                                ? Icons.dark_mode_outlined
                                : Icons.light_mode_outlined,
                            size: 18,
                            color: context.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Tema',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          ThemeToggleSwitch(
                            isDark: isDark,
                            onChanged: themeController.toggleTheme,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            Icons.language,
                            size: 18,
                            color: context.textSecondary,
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Idioma',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            'Português',
                            style: TextStyle(
                              color: colors.accentBlue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: colors.accentBlue,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    Divider(color: colors.border),
                    const SizedBox(height: 8),
                    // --- Support section ---
                    Text(
                      'SUPORTE',

                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    Column(
                      children: [
                        DrawerNavItem(
                          icon: Icons.help_center_outlined,
                          label: 'Central de Ajuda',
                          selected: false,
                          onTap: () {
                            Navigator.of(context).pop(); // close drawer
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const HelpCenterScreen(),
                              ),
                            );
                          },
                        ),
                        DrawerNavItem(
                          icon: Icons.info_outline,
                          label: 'Sobre Loah',
                          selected: false,
                          onTap: () {
                            Navigator.of(context).pop(); // close drawer
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const AboutLoahScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    Divider(color: colors.border),
                    const SizedBox(height: 8),
                    Text(
                      'CONTA',
                      style: TextStyle(
                        fontSize: 11,
                        letterSpacing: 0.6,
                        fontWeight: FontWeight.w600,
                        color: context.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        DrawerNavItem(
                          icon: Icons.lock_outline,
                          label: 'Alterar senha',
                          selected: false,
                          onTap: () {
                            Navigator.of(context).pop();
                            // Placeholder: no navigation yet.
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.of(context).pop(); // close drawer
                          // Faz logout no Firebase Auth, eliminando o token
                          // de refresh persistido no dispositivo. Isto força
                          // o utilizador a fazer login novamente na próxima
                          // vez que abrir o app.
                          await AuthService().signOut();
                          if (!context.mounted) return;
                          // Remove todo o stack de navegação e volta ao login
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(
                          Icons.logout,
                          size: 18,
                          color: Colors.redAccent,
                        ),
                        label: const Text(
                          'Sair',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.redAccent),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Center(
                      child: Text(
                        'Loah v2.4.0 • Made with Precision',
                        style: TextStyle(
                          fontSize: 10.5,
                          color: context.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

