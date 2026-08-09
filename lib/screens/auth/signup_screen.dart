import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/l10n/app_localizations.dart';
import 'package:loah_app/core/services/auth_service.dart';
import 'package:loah_app/core/services/user_service.dart';
import 'package:loah_app/screens/auth/email_verification_screen.dart';
import 'package:loah_app/screens/contacts/widgets/country_code_picker_sheet.dart';
import 'package:loah_app/screens/support/terms_privacy_screen.dart';
import 'widgets/wave_lines/wave_card_header.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  String _dialCode = '+351';
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptedTerms = false;
  bool _showTermsError = false;
  bool _submitting = false;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value, AppLocales loc) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return loc.translate('signup_nome_obrigatorio');
    if (!v.contains(' ')) return loc.translate('signup_nome_sobrenome');
    return null;
  }

  String? _validateEmail(String? value, AppLocales loc) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return loc.translate('signup_email_obrigatorio');
    if (!_emailRegex.hasMatch(v)) return loc.translate('signup_email_invalido');
    return null;
  }

  String? _validatePhone(String? value, AppLocales loc) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return loc.translate('signup_telefone_obrigatorio');
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return loc.translate('signup_telefone_invalido');
    return null;
  }

  String? _validatePassword(String? value, AppLocales loc) {
    final v = value ?? '';
    if (v.isEmpty) return loc.translate('signup_senha_obrigatoria');
    if (v.length < 8) return loc.translate('signup_senha_minima');
    return null;
  }

  String? _validateConfirmPassword(String? value, AppLocales loc) {
    final v = value ?? '';
    if (v.isEmpty) return loc.translate('signup_confirmar_obrigatoria');
    if (v != _passwordController.text) return loc.translate('signup_senhas_nao_coincidem');
    return null;
  }

  Future<void> _onPickDialCode() async {
    final res = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (_) => const CountryCodePickerSheet(),
    );
    if (res == null || !mounted) return;
    final parts = res.split('|');
    if (parts.length == 2) {
      setState(() => _dialCode = parts[1]);
    }
  }

  Future<void> _onSubmit() async {
    final loc = AppLocales.of(context);
    final form = _formKey.currentState;
    final formValid = form?.validate() ?? false;
    setState(() => _showTermsError = !_acceptedTerms);
    if (!formValid || !_acceptedTerms) return;

setState(() => _submitting = true);

    try {
      final userCredential = await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Reativa a rede do Firestore que foi desligada no logout,
      // caso contrário a escrita do perfil abaixo fica pendurada.
      await FirebaseFirestore.instance.enableNetwork();

      await _userService.updateDisplayName(_nameController.text.trim());

      await _userService.createUserProfile(
        uid: userCredential.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        dialCode: _dialCode,
      );

      if (!mounted) return;

      // Envia email de verificação e redireciona para a tela de verificação
      await _authService.sendEmailVerification();
      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => EmailVerificationScreen(
            email: _emailController.text.trim(),
          ),
        ),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = loc.translate('signup_email_em_uso');
          break;
        case 'weak-password':
          message = loc.translate('signup_senha_fraca');
          break;
        case 'invalid-email':
          message = loc.translate('signup_email_invalido');
          break;
        default:
          message = '${loc.translate('signup_erro_criar')}${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('auth_erro_inesperado')}$e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    required ColorScheme scheme,
    required Color border,
    required Color fillColor,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: fillColor,
      contentPadding: const EdgeInsets.symmetric(vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: scheme.primary),
      ),
    );
  }

Future<void> _handleGoogleSignUp() async {
    final loc = AppLocales.of(context);
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (!mounted) return;
      final user = userCredential.user;
      if (user != null) {
        // Reativa a rede do Firestore que foi desligada no logout.
        await FirebaseFirestore.instance.enableNetwork();
        await _userService.createUserProfile(
          uid: user.uid,
          name: user.displayName ?? 'Usuario',
          email: user.email ?? '',
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              email: user.email ?? '',
            ),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code != 'canceled') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('auth_erro_google')}${e.message}')),
        );
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      String message;
      if (e.code == 'permission-denied') {
        message = loc.translate('auth_permissao_denegada');
      } else {
        message = '${loc.translate('auth_erro_firestore')}${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('auth_erro_inesperado')}$e')),
      );
    }
  }

  Future<void> _handleAppleSignUp() async {
    final loc = AppLocales.of(context);
    // Verifica se a plataforma é Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('auth_apple_so_ios')),
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      final userCredential = await _authService.signInWithApple();
      if (!mounted) return;
final user = userCredential.user;
      if (user != null) {
        // Reativa a rede do Firestore que foi desligada no logout.
        await FirebaseFirestore.instance.enableNetwork();
        await _userService.createUserProfile(
          uid: user.uid,
          name: user.displayName ?? 'Usuario Apple',
          email: user.email ?? '',
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => EmailVerificationScreen(
              email: user.email ?? '',
            ),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code != 'canceled') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${loc.translate('auth_erro_apple')}${e.message}')),
        );
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;
      String message;
      if (e.code == 'permission-denied') {
        message = loc.translate('auth_permissao_denegada');
      } else {
        message = '${loc.translate('auth_erro_firestore')}${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('auth_erro_inesperado')}$e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocales.of(context);
    final textSecondary = scheme.onSurface.withValues(alpha: 0.65);
    final border = scheme.onSurface.withValues(alpha: 0.14);
    final cardBackground = scheme.surface;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 420 ? 18.0 : 28.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 0),
                    WaveCardHeader(
                      backgroundColor: scheme.primary,
                      lineColor: Colors.white,
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            loc.translate('signup_titulo'),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            loc.translate('signup_subtitulo'),
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    _FieldLabel(text: loc.translate('signup_nome_label'), color: textSecondary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_submitting,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        hint: loc.translate('signup_nome_hint'),
                        icon: Icons.person_outline_rounded,
                        scheme: scheme,
                        border: border,
                        fillColor: cardBackground,
                      ),
                      validator: (v) => _validateName(v, loc),
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(text: loc.translate('signup_email_label'), color: textSecondary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_submitting,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        hint: loc.translate('signup_email_hint'),
                        icon: Icons.mail_outline_rounded,
                        scheme: scheme,
                        border: border,
                        fillColor: cardBackground,
                      ),
                      validator: (v) => _validateEmail(v, loc),
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(text: loc.translate('signup_telefone_label'), color: textSecondary),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        SizedBox(
                          width: 128,
                          child: InkWell(
                            onTap: _onPickDialCode,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                              decoration: BoxDecoration(
                                color: cardBackground,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: border),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.flag_outlined, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _dialCode,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.arrow_drop_down_rounded),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _phoneNumberController,
                            enabled: !_submitting,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            decoration: _fieldDecoration(
                              hint: loc.translate('signup_telefone_hint'),
                              icon: Icons.phone_android_outlined,
                              scheme: scheme,
                              border: border,
                              fillColor: cardBackground,
                            ),
                            validator: (v) => _validatePhone(v, loc),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(text: loc.translate('signup_senha_label'), color: textSecondary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_submitting,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        hint: loc.translate('signup_senha_hint'),
                        icon: Icons.lock_outline_rounded,
                        scheme: scheme,
                        border: border,
                        fillColor: cardBackground,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                      ),
                      validator: (v) => _validatePassword(v, loc),
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).nextFocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(text: loc.translate('signup_confirmar_senha_label'), color: textSecondary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !_submitting,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: _fieldDecoration(
                        hint: loc.translate('signup_confirmar_senha_hint'),
                        icon: Icons.lock_outline_rounded,
                        scheme: scheme,
                        border: border,
                        fillColor: cardBackground,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirmPassword = !_obscureConfirmPassword,
                          ),
                        ),
                      ),
                      validator: (v) => _validateConfirmPassword(v, loc),
                      onFieldSubmitted: (_) => _onSubmit(),
                    ),
                    const SizedBox(height: 16),
                    _TermsCheckbox(
                      value: _acceptedTerms,
                      showError: _showTermsError,
                      scheme: scheme,
                      textSecondary: textSecondary,
                      loc: loc,
                      onChanged: (v) {
                        setState(() {
                          _acceptedTerms = v ?? false;
                          if (_acceptedTerms) _showTermsError = false;
                        });
                      },
                      onTermsTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsPrivacyScreen(),
                          ),
                        );
                      },
                      onPrivacyTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const TermsPrivacyScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submitting ? null : _onSubmit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _submitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    loc.translate('signup_criar_conta'),
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward_rounded, size: 20),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(child: Divider(thickness: 1, height: 1, color: border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            loc.translate('signup_ou_cadastre_com'),
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: textSecondary,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(thickness: 1, height: 1, color: border)),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.g_mobiledata_rounded,
                            label: 'Google',
                            scheme: scheme,
                            border: border,
                            onTap: _submitting ? null : _handleGoogleSignUp,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SocialButton(
                            icon: Icons.apple_rounded,
                            label: 'Apple',
                            scheme: scheme,
                            border: border,
                            onTap: _submitting ? null : _handleAppleSignUp,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Center(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        children: [
                          Text(
                            loc.translate('signup_ja_tem_conta'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: scheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).maybePop(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              loc.translate('signup_entrar'),
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: scheme.primary,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TermsCheckbox extends StatelessWidget {
  final bool value;
  final bool showError;
  final ColorScheme scheme;
  final Color textSecondary;
  final AppLocales loc;
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const _TermsCheckbox({
    required this.value,
    required this.showError,
    required this.scheme,
    required this.textSecondary,
    required this.loc,
    required this.onChanged,
    required this.onTermsTap,
    required this.onPrivacyTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final linkStyle = theme.textTheme.bodySmall?.copyWith(
      color: scheme.primary,
      fontWeight: FontWeight.w800,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Checkbox(
                value: value,
                onChanged: onChanged,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                side: BorderSide(
                  width: 1.5,
                  color: showError
                      ? scheme.error
                      : scheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 3),
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: textSecondary,
                      height: 1.35,
                    ),
                    children: [
                      TextSpan(text: loc.translate('signup_aceito_termos')),
                      TextSpan(
                        text: loc.translate('signup_termos_condicoes'),
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                      ),
                      TextSpan(text: loc.translate('signup_e_privacidade')),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        if (showError)
          Padding(
            padding: const EdgeInsets.only(left: 34, top: 4),
            child: Text(
              loc.translate('signup_aceitar_termos_erro'),
              style: theme.textTheme.bodySmall?.copyWith(color: scheme.error),
            ),
          ),
      ],
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final Color color;

  const _FieldLabel({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      text,
      style: theme.textTheme.labelSmall?.copyWith(
        color: color,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.6,
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme scheme;
  final Color border;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    required this.scheme,
    required this.border,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: scheme.onSurface),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: scheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
