import 'package:flutter/material.dart';
import 'package:loah_app/core/l10n/app_localizations.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import 'package:loah_app/main.dart';

/// Onboarding screen — exibido apenas na primeira vez que o utilizador
/// cria uma conta (após login/signup bem-sucedido, antes do RootShell).
///
/// Mostra 3 páginas de boas-vindas com funcionalidades principais do app.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToNext() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const RootShell()),
      (route) => false,
    );
  }

  List<_OnboardingPageData> _buildPages(AppLocales loc) {
    return [
      _OnboardingPageData(
        icon: Icons.track_changes_outlined,
        title: loc.translate('onb_meta_titulo'),
        description: loc.translate('onb_meta_desc'),
        color: AppColors.primary,
      ),
      _OnboardingPageData(
        icon: Icons.check_circle_outline,
        title: loc.translate('onb_tarefa_titulo'),
        description: loc.translate('onb_tarefa_desc'),
        color: AppColors.success,
      ),
      _OnboardingPageData(
        icon: Icons.account_balance_wallet_outlined,
        title: loc.translate('onb_financa_titulo'),
        description: loc.translate('onb_financa_desc'),
        color: AppColors.primaryLight,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocales.of(context);
    final pages = _buildPages(loc);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Skip button ──
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _finishOnboarding,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                child: Text(
                  loc.translate('onb_pular'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: scheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // ── Pages ──
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: pages.length,
                itemBuilder: (context, index) {
                  final page = pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            color: page.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            page.icon,
                            size: 64,
                            color: page.color,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: scheme.onSurface.withValues(alpha: 0.7),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ── Dot indicators ──
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                final isActive = index == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: isActive ? scheme.primary : scheme.primary.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),

            const SizedBox(height: 32),

            // ── Continue button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _goToNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _currentPage < pages.length - 1
                            ? loc.translate('onb_continuar')
                            : loc.translate('onb_comecar'),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _currentPage < pages.length - 1
                            ? Icons.arrow_forward_rounded
                            : Icons.check_rounded,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPageData {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}
