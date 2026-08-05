import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ── App controllers / localization ──────────────────────────────────
import 'package:loah_app/core/l10n/app_localizations.dart';
import 'package:loah_app/core/l10n/locale_controller.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/core/theme/theme_controller.dart';

// ── Auth-flow screens ───────────────────────────────────────────────
import 'package:loah_app/screens/onboarding/onboarding_screen.dart';

/// Wraps [child] in the app's InheritedWidget controllers + a MaterialApp
/// using the real light theme, so widgets that read `context.loahColors`,
/// `AppLocales.of(context)` and `LoahThemeController.of(context)` render
/// correctly in tests.
Widget wrapLoah(Widget child, {Locale locale = const Locale('pt')}) {
  return LoahThemeController(
    themeMode: ThemeMode.light,
    toggleTheme: () {},
    child: LocaleController(
      locale: locale,
      onLocaleChanged: (_) {},
      child: MaterialApp(
        theme: AppTheme.light,
        home: child,
      ),
    ),
  );
}

void main() {
  // ═══════════════════════════════════════════════════════════════════
  // AppLocales — cobertura das chaves de tradução de auth/splash/onb.
  // puro Dart, sem Firebase.
  // ═══════════════════════════════════════════════════════════════════
  group('AppLocales — Auth flow keys', () {
    const pt = AppLocales(Locale('pt'));
    const en = AppLocales(Locale('en'));

    test('returns Portuguese by default / fallback', () {
      expect(pt.translate('auth_entrar'), 'Entrar');
      expect(pt.translate('signup_titulo'), 'Crie sua conta');
      expect(pt.translate('emailVer_verificar_titulo'), 'Verifique seu Email');
      expect(pt.translate('pwdRec_titulo'), 'Esqueceu a senha?');
      expect(pt.translate('resetPwd_definir'), 'Definir nova senha');
      expect(pt.translate('splash_subtitulo'), 'Sincronize sua vida');
      expect(pt.translate('onb_meta_titulo'), 'Defina Metas');
    });

    test('returns English translations when locale is en', () {
      expect(en.translate('auth_entrar'), 'Sign In');
      expect(en.translate('signup_titulo'), 'Create your account');
      expect(en.translate('emailVer_verificar_titulo'), 'Verify your Email');
      expect(en.translate('pwdRec_titulo'), 'Forgot your password?');
      expect(en.translate('resetPwd_definir'), 'Set new password');
      expect(en.translate('splash_subtitulo'), 'Sync your life');
      expect(en.translate('onb_meta_titulo'), 'Set Goals');
    });

    test('falls back to key when translation is missing', () {
      expect(pt.translate('chave_inexistente'), 'chave_inexistente');
    });

    test('portuguese login-screen detail keys', () {
      expect(pt.translate('auth_bem_vindo_volta'), 'Bem-vindo de Volta');
      expect(pt.translate('auth_email_hint'), 'seu@email.com');
      expect(pt.translate('auth_esqueci_senha'), 'Esqueci minha senha');
      expect(pt.translate('auth_entrar_btn'), 'Entrar');
      expect(pt.translate('auth_ou_continue_com'), 'OU CONTINUE COM');
      expect(pt.translate('auth_nao_tem_conta'), 'Nao tem uma conta?');
      expect(pt.translate('auth_cadastre_se'), 'Cadastre-se');
    });

    test('english login-screen detail keys', () {
      expect(en.translate('auth_bem_vindo_volta'), 'Welcome Back');
      expect(en.translate('auth_email_hint'), 'your@email.com');
      expect(en.translate('auth_esqueci_senha'), 'Forgot my password');
      expect(en.translate('auth_entrar_btn'), 'Sign In');
      expect(en.translate('auth_ou_continue_com'), 'OR CONTINUE WITH');
      expect(en.translate('auth_nao_tem_conta'), "Don't have an account?");
      expect(en.translate('auth_cadastre_se'), 'Sign Up');
    });

    test('signup keys are present in both languages', () {
      for (final key in const [
        'signup_titulo',
        'signup_nome_label',
        'signup_email_label',
        'signup_telefone_label',
        'signup_senha_label',
        'signup_confirmar_senha_label',
        'signup_criar_conta',
        'signup_ou_cadastre_com',
        'signup_ja_tem_conta',
        'signup_entrar',
      ]) {
        expect(pt.translate(key), isNot(key), reason: 'pt[$key] deve traduzir');
        expect(en.translate(key), isNot(key), reason: 'en[$key] deve traduzir');
      }
    });

    test('email verification keys are present in both languages', () {
      for (final key in const [
        'emailVer_verificar_titulo',
        'emailVer_enviamos_para',
        'emailVer_instrucoes',
        'emailVer_ja_verifiquei',
        'emailVer_reenviar',
        'emailVer_nao_recebeu',
        'emailVer_dica_spam',
        'emailVer_voltar_login',
      ]) {
        expect(pt.translate(key), isNot(key));
        expect(en.translate(key), isNot(key));
      }
    });

    test('password recovery keys are present in both languages', () {
      for (final key in const [
        'pwdRec_titulo',
        'pwdRec_subtitulo',
        'pwdRec_email_label',
        'pwdRec_email_hint',
        'pwdRec_enviar',
        'pwdRec_voltar_login',
        'pwdRec_spam',
      ]) {
        expect(pt.translate(key), isNot(key));
        expect(en.translate(key), isNot(key));
      }
    });

    test('reset password keys are present in both languages', () {
      for (final key in const [
        'resetPwd_definir',
        'resetPwd_subtitulo',
        'resetPwd_nova_label',
        'resetPwd_confirmar_label',
        'resetPwd_botao',
        'resetPwd_voltar_login',
      ]) {
        expect(pt.translate(key), isNot(key));
        expect(en.translate(key), isNot(key));
      }
    });

    test('splash keys are present in both languages', () {
      expect(pt.translate('splash_subtitulo'), 'Sincronize sua vida');
      expect(pt.translate('splash_tagline'), isNot('splash_tagline'));
      expect(en.translate('splash_tagline'), isNot('splash_tagline'));
    });

    test('onboarding keys are present in both languages', () {
      for (final key in const [
        'onb_meta_titulo',
        'onb_meta_desc',
        'onb_tarefa_titulo',
        'onb_tarefa_desc',
        'onb_financa_titulo',
        'onb_financa_desc',
        'onb_pular',
        'onb_continuar',
        'onb_comecar',
      ]) {
        expect(pt.translate(key), isNot(key));
        expect(en.translate(key), isNot(key));
      }
    });
  });

  // ═══════════════════════════════════════════════════════════════════
  // OnboardingScreen — fluxo de onboarding (parte do fluxo de auth,
  // exibido após o cadastro/verificação). Sem dependência de Firebase,
  // pode ser testado como widget.
  // ═══════════════════════════════════════════════════════════════════
  group('OnboardingScreen', () {
    testWidgets('renders first page in Portuguese', (tester) async {
      await tester.pumpWidget(wrapLoah(const OnboardingScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Defina Metas'), findsOneWidget);
      expect(find.text('Pular'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);
      expect(
        find.textContaining('Estabeleça metas pessoais'),
        findsOneWidget,
      );
    });

    testWidgets('renders first page in English', (tester) async {
      await tester.pumpWidget(
        wrapLoah(const OnboardingScreen(), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Set Goals'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.textContaining('Set personal, financial'), findsOneWidget);
    });

    testWidgets('swipes through pages and updates localized labels',
        (tester) async {
      await tester.pumpWidget(wrapLoah(const OnboardingScreen()));
      await tester.pumpAndSettle();

      // Página 0
      expect(find.text('Defina Metas'), findsOneWidget);
      expect(find.text('Continuar'), findsOneWidget);

      // Página 1
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Gerencie Tarefas'), findsOneWidget);

      // Página 2 — último botão vira "Começar a usar Loah"
      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Controle Finanças'), findsOneWidget);
      expect(find.text('Começar a usar Loah'), findsOneWidget);
    });

    testWidgets('swipes through pages in English', (tester) async {
      await tester.pumpWidget(
        wrapLoah(const OnboardingScreen(), locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Set Goals'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Manage Tasks'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('Control Finances'), findsOneWidget);
      expect(find.text('Start using Loah'), findsOneWidget);
    });

    testWidgets('Continue button advances to next page', (tester) async {
      await tester.pumpWidget(wrapLoah(const OnboardingScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Defina Metas'), findsOneWidget);

      await tester.tap(find.text('Continuar'));
      await tester.pumpAndSettle();

      expect(find.text('Gerencie Tarefas'), findsOneWidget);
    });
  });
}
