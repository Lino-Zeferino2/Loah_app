import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/services/auth_service.dart';
import 'package:loah_app/core/services/user_service.dart';
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
///
/// O nome, email e role sao carregados automaticamente do Firebase
/// Auth + Firestore — nao sao mais parametros estaticos.
class LoahDrawer extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onNavigate;

  const LoahDrawer({
    super.key,
    required this.currentIndex,
    required this.onNavigate,
  });

  @override
  State<LoahDrawer> createState() => _LoahDrawerState();
}

class _LoahDrawerState extends State<LoahDrawer> {
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';
  bool _loadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null) {
        // Dados do Firebase Auth (disponiveis offline)
        final displayName = firebaseUser.displayName ?? 'Utilizador';
        final email = firebaseUser.email ?? '';

        // Dados do Firestore (role + nome completo salvo no cadastro)
        final doc = await UserService().getUserProfile(firebaseUser.uid);
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              _userName = (data['name'] as String?)?.trim() ?? displayName;
              _userEmail = (data['email'] as String?)?.trim() ?? email;
              _userRole = data['role'] ?? 'user';
              _loadingProfile = false;
            });
          }
          return;
        }

        // Fallback: apenas dados do Auth
        if (mounted) {
          setState(() {
            _userName = displayName;
            _userEmail = email;
            _loadingProfile = false;
          });
        }
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingProfile = false);
  }

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
                          _loadingProfile
                              ? SizedBox(
                                  width: 80,
                                  height: 14,
                                  child: LinearProgressIndicator(
                                    backgroundColor: colors.cardBackgroundAlt,
                                  ),
                                )
                              : Text(
                                  _userName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                          Row(
                            children: [
                              _loadingProfile
                                  ? SizedBox(
                                      width: 100,
                                      height: 12,
                                      child: LinearProgressIndicator(
                                        backgroundColor: colors.cardBackgroundAlt,
                                      ),
                                    )
                                  : Text(
                                      _userEmail,
                                      style: TextStyle(
                                        color: colors.accentBlue,
                                        fontSize: 12.5,
                                      ),
                                    ),
                              if (!_loadingProfile && _userRole == 'admin') ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade700,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Admin',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
                        selected: i == widget.currentIndex,
                        onTap: () {
                          Navigator.of(context).pop(); // close drawer
                          widget.onNavigate(i);
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

