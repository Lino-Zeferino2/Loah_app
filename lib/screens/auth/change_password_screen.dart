import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Informe sua senha atual';
    return null;
  }

  String? _validateNewPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Informe a nova senha';
    if (v.length < 6) return 'A nova senha deve ter pelo menos 6 caracteres';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Confirme a nova senha';
    if (v != _newPasswordController.text) return 'As senhas nao coincidem';
    return null;
  }

  Future<void> _onSubmit() async {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _submitting = true);

    try {
      await _authService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha alterada com sucesso!'),
          backgroundColor: Color(0xFF2ECC71),
        ),
      );

      Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Senha atual incorreta';
          break;
        case 'weak-password':
          message = 'A nova senha e muito fraca';
          break;
        case 'requires-recent-login':
          message = 'Faca login novamente antes de alterar a senha';
          break;
        default:
          message = 'Erro ao alterar senha: ${e.message}';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textSecondary = scheme.onSurface.withValues(alpha: 0.65);
    final border = scheme.onSurface.withValues(alpha: 0.14);
    final cardBackground = scheme.surface;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alterar Senha'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
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
                    const SizedBox(height: 12),

                    // Ilustracao / icone de seguranca
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: scheme.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.lock_outline_rounded,
                          size: 38,
                          color: scheme.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Digite sua senha atual e escolha uma nova senha segura.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: textSecondary,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 28),

                    // ── Senha Atual ──
                    _FieldLabel(text: 'SENHA ATUAL', color: textSecondary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _currentPasswordController,
                      enabled: !_submitting,
                      obscureText: _obscureCurrent,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        hint: '*******',
                        icon: Icons.lock_outline_rounded,
                        scheme: scheme,
                        border: border,
                        fillColor: cardBackground,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureCurrent
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscureCurrent = !_obscureCurrent,
                          ),
                        ),
                      ),
                      validator: _validateCurrentPassword,
                    ),

                    const SizedBox(height: 18),

                    // ── Nova Senha ──
                    _FieldLabel(text: 'NOVA SENHA', color: textSecondary),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _newPasswordController,
                      enabled: !_submitting,
                      obscureText: _obscureNew,
                      textInputAction: TextInputAction.next,
                      decoration: _inputDecoration(
                        hint: 'Minimo 6 caracteres',
                        icon: Icons.lock_outline_rounded,
                        scheme: scheme,
                        border: border,
                        fillColor: cardBackground,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscureNew = !_obscureNew,
                          ),
                        ),
                      ),
                      validator: _validateNewPassword,
                    ),

                    const SizedBox(height: 18),

                    // ── Confirmar Nova Senha ──
                    _FieldLabel(
                      text: 'CONFIRMAR NOVA SENHA',
                      color: textSecondary,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      enabled: !_submitting,
                      obscureText: _obscureConfirm,
                      textInputAction: TextInputAction.done,
                      decoration: _inputDecoration(
                        hint: 'Digite novamente',
                        icon: Icons.lock_outline_rounded,
                        scheme: scheme,
                        border: border,
                        fillColor: cardBackground,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                      ),
                      validator: _validateConfirmPassword,
                      onFieldSubmitted: (_) => _onSubmit(),
                    ),

                    const SizedBox(height: 28),

                    // ── Botao Alterar Senha ──
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Alterar Senha',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
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

