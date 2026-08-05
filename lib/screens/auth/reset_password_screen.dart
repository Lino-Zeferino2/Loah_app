import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loah_app/core/l10n/app_localizations.dart';
import 'package:loah_app/core/services/auth_service.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/screens/auth/login_screen.dart';

/// Ecrã de definição de nova senha — apresentado quando o utilizador
/// abre o deep link de "redefinir senha" enviado por email.
///
/// Recebe o `oobCode` gerado pelo Firebase Auth e permite ao utilizador
/// escolher uma nova senha. Após confirmar, volta para o login.
class ResetPasswordScreen extends StatefulWidget {
  final String oobCode;

  const ResetPasswordScreen({super.key, required this.oobCode});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _submitting = false;
  bool _checkingCode = true;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _validateCode();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Valida o oobCode junto do Firebase antes de exibir o formulário.
  Future<void> _validateCode() async {
    final loc = AppLocales.of(context);
    try {
      await _authService.verifyPasswordResetCode(widget.oobCode);
      if (!mounted) return;
      setState(() {
        _checkingCode = false;
        _errorMessage = null;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _checkingCode = false;
        _errorMessage = _codeErrorMessage(e.code, loc);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _checkingCode = false;
        _errorMessage = '${loc.translate('auth_erro_inesperado')}$e';
      });
    }
  }

  String _codeErrorMessage(String code, AppLocales loc) {
    switch (code) {
      case 'expired-action-code':
        return loc.translate('resetPwd_erro_expirado');
      case 'invalid-action-code':
        return loc.translate('resetPwd_erro_invalido');
      case 'user-disabled':
        return loc.translate('resetPwd_erro_desativado');
      case 'user-not-found':
        return loc.translate('resetPwd_erro_nao_encontrado');
      default:
        return loc.translate('resetPwd_erro_validar');
    }
  }

  String? _validateNewPassword(String? value, AppLocales loc) {
    final v = value ?? '';
    if (v.isEmpty) return loc.translate('resetPwd_obrigatoria');
    if (v.length < 6) return loc.translate('resetPwd_minima');
    return null;
  }

  String? _validateConfirm(String? value, AppLocales loc) {
    final v = value ?? '';
    if (v.isEmpty) return loc.translate('resetPwd_confirmar_obrigatoria');
    if (v != _newPasswordController.text) return loc.translate('resetPwd_nao_coincidem');
    return null;
  }

  Future<void> _onSubmit() async {
    final loc = AppLocales.of(context);
    final form = _formKey.currentState;
    if (form == null || !form.validate()) return;

    setState(() => _submitting = true);

    try {
      await _authService.resetPassword(
        oobCode: widget.oobCode,
        newPassword: _newPasswordController.text,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.translate('resetPwd_sucesso')),
          backgroundColor: const Color(0xFF2ECC71),
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'weak-password':
          message = loc.translate('resetPwd_fraca');
          break;
        case 'expired-action-code':
          message = loc.translate('resetPwd_expirado_curto');
          break;
        case 'invalid-action-code':
          message = loc.translate('resetPwd_invalido_curto');
          break;
        default:
          message = '${loc.translate('resetPwd_erro_redefinir')}${e.message}';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loahColors = context.loahColors;
    final textSec = context.textSecondary;
    final loc = AppLocales.of(context);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, scheme, textSec, loc),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      _buildSecurityBadge(loahColors),
                      const SizedBox(height: 28),
                      _buildCard(context, scheme, loahColors, textSec, loc),
                      const SizedBox(height: 40),
                      Text(
                        '© 2026 LOAH DIGITAL ECOSYSTEM',
                        style: TextStyle(
                          color: textSec,
                          fontSize: 11,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme, Color textSec, AppLocales loc) {
    return Container(
      height: 56,
      color: AppColors.darkSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.maybePop(context),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.arrow_back, color: scheme.primary, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    loc.translate('common_voltar'),
                    style: TextStyle(
                      color: scheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Text(
            'Loah',
            style: TextStyle(
              color: scheme.onPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(LoahColors loahColors) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        color: loahColors.cardBackground,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.password_rounded,
          color: loahColors.accentBlue,
          size: 34,
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, ColorScheme scheme, LoahColors loahColors, Color textSec, AppLocales loc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: loahColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: _checkingCode
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : _errorMessage != null
              ? _buildErrorState(scheme, textSec, loc)
              : _buildForm(scheme, textSec, loc),
    );
  }

  Widget _buildErrorState(ColorScheme scheme, Color textSec, AppLocales loc) {
    return Column(
      children: [
        Icon(Icons.error_outline_rounded, color: scheme.error, size: 48),
        const SizedBox(height: 16),
        Text(
          _errorMessage!,
          textAlign: TextAlign.center,
          style: TextStyle(color: textSec, fontSize: 14, height: 1.45),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              loc.translate('resetPwd_voltar_login'),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(ColorScheme scheme, Color textSec, AppLocales loc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          loc.translate('resetPwd_definir'),
          style: TextStyle(
            color: scheme.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          loc.translate('resetPwd_subtitulo'),
          textAlign: TextAlign.center,
          style: TextStyle(color: textSec, fontSize: 13, height: 1.45),
        ),
        const SizedBox(height: 28),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                loc.translate('resetPwd_nova_label'),
                style: TextStyle(
                  color: textSec,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _newPasswordController,
                obscure: _obscureNew,
                onToggle: () => setState(() => _obscureNew = !_obscureNew),
                validator: (v) => _validateNewPassword(v, loc),
                hint: loc.translate('resetPwd_hint_min'),
              ),
              const SizedBox(height: 18),
              Text(
                loc.translate('resetPwd_confirmar_label'),
                style: TextStyle(
                  color: textSec,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _buildPasswordField(
                controller: _confirmPasswordController,
                obscure: _obscureConfirm,
                onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                validator: (v) => _validateConfirm(v, loc),
                hint: loc.translate('resetPwd_hint_confirmar'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
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
                      : Text(
                          loc.translate('resetPwd_botao'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    required String? Function(String?) validator,
    required String hint,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loahColors = context.loahColors;
    final textSec = context.textSecondary;

    return Container(
      decoration: BoxDecoration(
        color: loahColors.cardBackgroundAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: loahColors.border, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        validator: validator,
        style: TextStyle(color: scheme.onSurface, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textSec.withValues(alpha: 0.6), fontSize: 14),
          prefixIcon: Icon(Icons.lock_outline_rounded, color: textSec, size: 20),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
              color: textSec,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }
}
