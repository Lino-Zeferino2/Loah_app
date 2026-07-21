import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/services/auth_service.dart';
import 'package:loah_app/core/services/user_service.dart';
import 'package:loah_app/main.dart';
import 'package:loah_app/screens/contacts/widgets/country_code_picker_sheet.dart';
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

  String? _validateName(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu nome completo';
    if (!v.contains(' ')) return 'Informe nome e sobrenome';
    return null;
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu email';
    if (!_emailRegex.hasMatch(v)) return 'Email invalido';
    return null;
  }

  String? _validatePhone(String? value) {
    final raw = (value ?? '').trim();
    if (raw.isEmpty) return 'Informe seu numero de telemovel';
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return 'Numero de telemovel invalido';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Informe sua senha';
    if (v.length < 8) return 'A senha deve ter pelo menos 8 caracteres';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Confirme sua senha';
    if (v != _passwordController.text) return 'As senhas nao coincidem';
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

      await _userService.updateDisplayName(_nameController.text.trim());

      await _userService.createUserProfile(
        uid: userCredential.user!.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        dialCode: _dialCode,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RootShell()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Este email ja esta em uso';
          break;
        case 'weak-password':
          message = 'Senha muito fraca';
          break;
        case 'invalid-email':
          message = 'Email invalido';
          break;
        default:
          message = 'Erro ao criar conta: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
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
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (!mounted) return;
      final user = userCredential.user;
      if (user != null) {
        await _userService.createUserProfile(
          uid: user.uid,
          name: user.displayName ?? 'Usuario',
          email: user.email ?? '',
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RootShell()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code != 'canceled') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro Google: ${e.message}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  Future<void> _handleAppleSignUp() async {
    try {
      final userCredential = await _authService.signInWithApple();
      if (!mounted) return;
      final user = userCredential.user;
      if (user != null) {
        await _userService.createUserProfile(
          uid: user.uid,
          name: user.displayName ?? 'Usuario Apple',
          email: user.email ?? '',
        );
        if (!mounted) return;
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RootShell()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      if (e.code != 'canceled') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro Apple: ${e.message}')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
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
                            'Crie sua conta',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Junte-se a comunidade Loah e comece sua jornada hoje.',
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
                    _FieldLabel(text: 'Nome completo', color: textSecondary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      enabled: !_submitting,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        hint: 'Ex: Maria Silva',
                        icon: Icons.person_outline_rounded,
                        scheme: scheme,
                        border: border,
                        fillColor: cardBackground,
                      ),
                      validator: _validateName,
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(text: 'E-mail', color: textSecondary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      enabled: !_submitting,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        hint: 'nome@exemplo.com',
                        icon: Icons.mail_outline_rounded,
                        scheme: scheme,
                        border: border,
                        fillColor: cardBackground,
                      ),
                      validator: _validateEmail,
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(text: 'Numero de telemovel', color: textSecondary),
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
                              hint: 'Ex: 9xx xxx xxx',
                              icon: Icons.phone_android_outlined,
                              scheme: scheme,
                              border: border,
                              fillColor: cardBackground,
                            ),
                            validator: _validatePhone,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(text: 'Senha', color: textSecondary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      enabled: !_submitting,
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      decoration: _fieldDecoration(
                        hint: 'Minimo 8 caracteres',
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
                      validator: _validatePassword,
                      onFieldSubmitted: (_) {
                        FocusScope.of(context).nextFocus();
                      },
                    ),
                    const SizedBox(height: 16),
                    _FieldLabel(text: 'Confirmar senha', color: textSecondary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !_submitting,
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      decoration: _fieldDecoration(
                        hint: 'Digite novamente',
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
                      validator: _validateConfirmPassword,
                      onFieldSubmitted: (_) => _onSubmit(),
                    ),
                    const SizedBox(height: 16),
                    _TermsCheckbox(
                      value: _acceptedTerms,
                      showError: _showTermsError,
                      scheme: scheme,
                      textSecondary: textSecondary,
                      onChanged: (v) {
                        setState(() {
                          _acceptedTerms = v ?? false;
                          if (_acceptedTerms) _showTermsError = false;
                        });
                      },
                      onTermsTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Termos e condicoes')),
                        );
                      },
                      onPrivacyTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Politica de privacidade')),
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
                                    'Criar Conta',
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
                            'OU CADASTRE-SE COM',
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
                            'Ja tem uma conta?',
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
                              'Entrar',
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
  final ValueChanged<bool?> onChanged;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;

  const _TermsCheckbox({
    required this.value,
    required this.showError,
    required this.scheme,
    required this.textSecondary,
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
                      const TextSpan(text: 'Aceito os '),
                      TextSpan(
                        text: 'termos e condicoes',
                        style: linkStyle,
                        recognizer: TapGestureRecognizer()..onTap = onTermsTap,
                      ),
                      const TextSpan(text: ' e a politica de privacidade da Loah.'),
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
              'E preciso aceitar os termos para continuar',
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
