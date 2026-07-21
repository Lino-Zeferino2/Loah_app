import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loah_app/core/services/auth_service.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/screens/auth/widgets/wave_lines/custom_input_field.dart';
import 'package:loah_app/screens/auth/widgets/wave_lines/primary_button.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _submitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendInstructions() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe seu email')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      await _authService.sendPasswordResetEmail(email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email de redefinicao enviado para $email')),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Email invalido';
          break;
        case 'user-not-found':
          message = 'Usuario nao encontrado';
          break;
        default:
          message = 'Erro: ${e.message}';
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
    final loahColors = context.loahColors;
    final textSec = context.textSecondary;

    // Configura os ícones da barra de status (iOS/Android)
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

    return Scaffold(
      backgroundColor: scheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Header Topo
            _buildHeader(context, scheme, textSec),

            // Conteúdo Rolável e Responsivo
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                  child: Column(
                    children: [
                      // Ícone Circular Central de Segurançao/Cadeado
                      _buildSecurityBadge(loahColors),

                      const SizedBox(height: 28),

                      // Card Principal de Recuperação
                      _buildRecoveryCard(context, scheme, loahColors, textSec),

                      const SizedBox(height: 40),

                      // Rodapé / Copyright
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

  /// Cabeçalho com botão "Voltar" e o Título "Loah"
  Widget _buildHeader(BuildContext context, ColorScheme scheme, Color textSec) {
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
                    'Voltar',
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

  /// Badge de Ícone Circular
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
          Icons.lock_reset_rounded,
          color: loahColors.accentBlue,
          size: 34,
        ),
      ),
    );
  }

  /// Card Escuro Contendo o Formulário
  Widget _buildRecoveryCard(
      BuildContext context, ColorScheme scheme, LoahColors loahColors, Color textSec) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Esqueceu a senha?',
            style: TextStyle(
              color: scheme.onSurface,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Não se preocupe! Insira o e-mail associado à sua conta e enviaremos instruções para redefinir sua senha.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textSec,
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),

          // Campo de Entrada do E-mail
          CustomInputField(
            label: 'E-mail',
            hintText: 'seu@email.com',
            prefixIcon: Icons.mail_outline_rounded,
            controller: _emailController,
          ),

          const SizedBox(height: 24),

          // Botão Ação
          PrimaryButton(
            text: 'Enviar Instruções',
            icon: Icons.send_rounded,
            isLoading: _submitting,
            onPressed: _submitting
                ? null
                : () {
                    _handleSendInstructions();
                  },
          ),

          const SizedBox(height: 28),

          // Link Voltar para o Login
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_back, color: textSec, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Voltar para o Login',
                  style: TextStyle(
                    color: scheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'O email pode parar no Span',
            style: TextStyle(color: scheme.error),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}