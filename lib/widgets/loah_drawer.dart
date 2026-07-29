import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/currency/currency_controller.dart';
import 'package:loah_app/core/l10n/app_localizations.dart';
import 'package:loah_app/core/l10n/locale_controller.dart';
import 'package:loah_app/core/services/auth_service.dart';
import 'package:loah_app/core/services/user_service.dart';
import 'package:loah_app/core/utils/currency_formatter.dart';
import 'package:loah_app/screens/admin/manage_about_loah_screen.dart';
import 'package:loah_app/screens/admin/manage_help_center_screen.dart';
import 'package:loah_app/screens/admin/manage_reflections_screen.dart';
import 'package:loah_app/screens/admin/manage_users_screen.dart';
import 'package:loah_app/screens/auth/change_password_screen.dart';
import 'package:loah_app/screens/auth/login_screen.dart';
import 'package:loah_app/screens/profile/profile_screen.dart';
import 'package:loah_app/widgets/loah_app_bar.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_controller.dart';
import '../screens/support/about_loah_screen.dart';
import '../screens/support/help_center_screen.dart';
import '../screens/support/terms_privacy_screen.dart';
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
    (icon: Icons.grid_view_rounded, key: 'drawer_dashboard'),
    (icon: Icons.track_changes_outlined, key: 'drawer_metas'),
    (icon: Icons.check_circle_outline, key: 'drawer_tarefas'),
    (icon: Icons.account_balance_wallet_outlined, key: 'drawer_financas'),
    (icon: Icons.contacts_outlined, key: 'drawer_contatos'),
  ];

  /// Abre um bottom sheet para o utilizador selecionar a moeda.
  void _showCurrencyPicker(BuildContext context) {
    final currencyController = CurrencyController.of(context);
    final currencies = CurrencyFormatter.supportedCurrencies;
    final currentCode = currencyController.currencyCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final searchController = TextEditingController();
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final query = searchController.text.trim().toLowerCase();
            final filtered = query.isEmpty
                ? currencies
                : currencies.where((c) =>
                    c.code.toLowerCase().contains(query) ||
                    c.name.toLowerCase().contains(query) ||
                    c.nameEn.toLowerCase().contains(query)).toList();

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              minChildSize: 0.4,
              expand: false,
              builder: (context, scrollController) => SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Text(
                        AppLocales.of(context).translate('currency_selecionar'),
                        style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: AppLocales.of(context).translate('currency_pesquisar'),
                          prefixIcon: const Icon(Icons.search, size: 20),
                          filled: true,
                          fillColor: context.loahColors.cardBackgroundAlt,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: (_) => setSheetState(() {}),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.separated(
                          controller: scrollController,
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final currency = filtered[index];
                            final isSelected = currency.code == currentCode;
                            return ListTile(
                              leading: Text(
                                currency.symbol,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: context.loahColors.accentBlue,
                                ),
                              ),
                              title: Text(
                                '${currency.code} - ${currency.name}',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(currency.nameEn),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: context.loahColors.accentBlue)
                                  : null,
                              onTap: () {
                                Navigator.of(ctx).pop();
                                if (currency.code != currentCode) {
                                  currencyController.onCurrencyChanged(currency.code);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Abre um bottom sheet para o utilizador selecionar o idioma.
  void _showLanguagePicker(BuildContext context) {
    final localeController = LocaleController.of(context);
    final currentLocale = localeController.locale.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppLocales.of(context).langSelecionar,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Português'),
                trailing: currentLocale == 'pt'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (currentLocale != 'pt') {
                    localeController.onLocaleChanged(const Locale('pt'));
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('English'),
                trailing: currentLocale == 'en'
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () {
                  Navigator.of(ctx).pop();
                  if (currentLocale != 'en') {
                    localeController.onLocaleChanged(const Locale('en'));
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                    if (!_loadingProfile && _userRole == 'admin')
                                      const Padding(
                                        padding: EdgeInsets.only(top: 4),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            borderRadius: BorderRadius.all(Radius.circular(6)),
                                          ),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            child: Text(
                                              'Admin',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
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
                        label: AppLocales.of(context).translate(_navItems[i].key),
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
                      AppLocales.of(context).drawerConfiguracoes,
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
                          Expanded(
                            child: Text(
                              AppLocales.of(context).drawerTema,
                              style: const TextStyle(fontWeight: FontWeight.w600),
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

                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showLanguagePicker(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.language,
                              size: 18,
                              color: context.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLocales.of(context).drawerIdioma,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              LocaleController.of(context).locale.languageCode == 'en'
                                  ? 'English'
                                  : 'Português',
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
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _showCurrencyPicker(context),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.attach_money,
                              size: 18,
                              color: context.textSecondary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                AppLocales.of(context).translate('drawer_moeda'),
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Text(
                              CurrencyController.of(context).currencyCode,
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
                    ),

                    const SizedBox(height: 14),

                    Divider(color: colors.border),
                    const SizedBox(height: 8),
                    // --- Support section ---
                    Text(
                      AppLocales.of(context).drawerSuporte,
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
                          label: AppLocales.of(context).drawerAjuda,
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
                          label: AppLocales.of(context).drawerSobre,
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
                        DrawerNavItem(
                          icon: Icons.description_outlined,
                          label: AppLocales.of(context).drawerTermos,
                          selected: false,
                          onTap: () {
                            Navigator.of(context).pop(); // close drawer
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const TermsPrivacyScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    // ── Admin section (only visible for admin users) ──
                    if (_userRole == 'admin') ...[
                      const SizedBox(height: 12),
                      Divider(color: colors.border),
                      const SizedBox(height: 8),
                      Text(
                        AppLocales.of(context).drawerAdmin,
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.6,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      const SizedBox(height: 10),
                      DrawerNavItem(
                        icon: Icons.people_outline,
                        label: AppLocales.of(context).drawerGerirUtilizadores,
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop(); // close drawer
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ManageUsersScreen(),
                            ),
                          );
                        },
                      ),
                      DrawerNavItem(
                        icon: Icons.auto_stories_outlined,
                        label: AppLocales.of(context).drawerGerirReflexoes,
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop(); // close drawer
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ManageReflectionsScreen(),
                            ),
                          );
                        },
                      ),
                      DrawerNavItem(
                        icon: Icons.support_agent_outlined,
                        label: AppLocales.of(context).drawerGerirAjuda,
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop(); // close drawer
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ManageHelpCenterScreen(),
                            ),
                          );
                        },
                      ),
                      DrawerNavItem(
                        icon: Icons.description_outlined,
                        label: AppLocales.of(context).drawerGerirSobre,
                        selected: false,
                        onTap: () {
                          Navigator.of(context).pop(); // close drawer
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ManageAboutLoahScreen(),
                            ),
                          );
                        },
                      ),
                    ],

                    const SizedBox(height: 12),
                    Divider(color: colors.border),
                    const SizedBox(height: 8),
                    Text(
                      AppLocales.of(context).drawerConta,
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
                          icon: Icons.person_outline,
                          label: AppLocales.of(context).drawerEditarPerfil,
                          selected: false,
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ProfileScreen(),
                              ),
                            );
                          },
                        ),
                        DrawerNavItem(
                          icon: Icons.lock_outline,
                          label: AppLocales.of(context).drawerAlterarSenha,
                          selected: false,
                          onTap: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen(),
                              ),
                            );
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
                          // 1) Desliga a rede do Firestore para interromper
                          //    todos os listeners ativos (IndexedStack mantém
                          //    as screens vivas com streams de tasks, contacts,
                          //    notifications, etc.) sem causar erros
                          //    PERMISSION_DENIED que podem travar a app.
                          await FirebaseFirestore.instance.disableNetwork();
                          // 2) Faz signOut para revogar o token Firebase
                          await AuthService().signOut();
                          // 3) Agora navega para o Login com stack limpo
                          if (!context.mounted) return;
                          await Navigator.of(context).pushAndRemoveUntil(
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
                        label: Text(
                          AppLocales.of(context).drawerSair,
                          style: const TextStyle(
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

