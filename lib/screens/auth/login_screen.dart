import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:loah_app/core/services/auth_service.dart';
import 'package:loah_app/core/services/user_service.dart';
import 'package:loah_app/main.dart';
import 'signup_screen.dart';
import 'widgets/wave_lines/wave_card_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  static final _emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$',
  );

  bool _obscure = true;
  bool _submitting = false;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Informe seu email';
    if (!_emailRegex.hasMatch(v)) return 'Email invalido';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Informe sua senha';
    if (v.length < 6) return 'Senha deve ter pelo menos 6 caracteres';
    return null;
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;

    setState(() => _submitting = true);

    try {
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
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
        case 'user-not-found':
          message = 'Usuario nao encontrado';
          break;
        case 'wrong-password':
          message = 'Senha incorreta';
          break;
        case 'invalid-email':
          message = 'Email invalido';
          break;
        case 'invalid-credential':
          message = 'Email ou senha incorretos';
          break;
        default:
          message = 'Erro ao entrar: ${e.message}';
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

  Future<void> _handlePasswordReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu email primeiro')),
      );
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email de redefinicao enviado para $email')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.message}')),
      );
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      final userCredential = await _authService.signInWithGoogle();
      if (!mounted) return;
      final user = userCredential.user;
      if (user != null) {
        final doc = await _userService.getUserProfile(user.uid);
        if (!doc.exists) {
          await _userService.createUserProfile(
            uid: user.uid,
            name: user.displayName ?? 'Usuario',
            email: user.email ?? '',
          );
        }
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
    } on FirebaseException catch (e) {
      if (!mounted) return;
      String message;
      if (e.code == 'permission-denied') {
        message = 'Erro de permissao ao acessar seus dados. '
            'As regras de seguranca do Firestore podem nao ter sido '
            'implantadas ainda. Contate o administrador.';
      } else {
        message = 'Erro no Firestore: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    }
  }

  Future<void> _handleAppleLogin() async {
    try {
      final userCredential = await _authService.signInWithApple();
      if (!mounted) return;
      final user = userCredential.user;
      if (user != null) {
        final doc = await _userService.getUserProfile(user.uid);
        if (!doc.exists) {
          await _userService.createUserProfile(
            uid: user.uid,
            name: user.displayName ?? 'Usuario Apple',
            email: user.email ?? '',
          );
        }
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
    } on FirebaseException catch (e) {
      if (!mounted) return;
      String message;
      if (e.code == 'permission-denied') {
        message = 'Erro de permissao ao acessar seus dados. '
            'As regras de seguranca do Firestore podem nao ter sido '
            'implantadas ainda. Contate o administrador.';
      } else {
        message = 'Erro no Firestore: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
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
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WaveCardHeader(
                        backgroundColor: scheme.primary,
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 12),
                            Text(
                              'Bem-vindo de Volta',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.4,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Entre com suas credenciais para aceder a sua conta Loah.',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _FieldLabel(text: 'E-MAIL', color: textSecondary),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _emailController,
                              enabled: !_submitting,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                hintText: 'seu@email.com',
                                prefixIcon: const Icon(Icons.mail_outline_rounded),
                                filled: true,
                                fillColor: cardBackground,
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
                              ),
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _FieldLabel(text: 'SENHA', color: textSecondary),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: _submitting ? null : _handlePasswordReset,
                                  child: Text(
                                    'Esqueci minha senha',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: scheme.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: _passwordController,
                              enabled: !_submitting,
                              obscureText: _obscure,
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                hintText: '*******',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscure
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () => setState(() => _obscure = !_obscure),
                                ),
                                filled: true,
                                fillColor: cardBackground,
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
                              ),
                              validator: _validatePassword,
                              onFieldSubmitted: (_) => _onSubmit(),
                            ),
                            const SizedBox(height: 24),
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
                                            'Entrar',
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
                            const SizedBox(height: 32),
                            Row(
                              children: [
                                Expanded(child: Divider(thickness: 1, height: 1, color: border)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text(
                                    'OU CONTINUE COM',
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
                                    icon: const FaIcon(FontAwesomeIcons.google, size: 16),
                                    label: 'Google',
                                    onTap: _submitting ? null : _handleGoogleLogin,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _SocialButton(
                                    icon: const FaIcon(FontAwesomeIcons.apple, size: 18),
                                    label: 'Apple',
                                    onTap: _submitting ? null : _handleAppleLogin,
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
                                    'Nao tem uma conta?',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: scheme.onSurface,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(builder: (_) => const SignupScreen()),
                                      );
                                    },
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Cadastre-se',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: scheme.primary,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final border = scheme.onSurface.withValues(alpha: 0.14);

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
            icon,
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
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
