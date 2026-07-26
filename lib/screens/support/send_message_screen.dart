import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/services/help_center_service.dart';
import 'package:loah_app/core/services/user_service.dart';
import 'package:loah_app/models/help_center_models.dart';

/// Screen where users can send a support message to the admin team.
class SendMessageScreen extends StatefulWidget {
  const SendMessageScreen({super.key});

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  final HelpCenterService _service = HelpCenterService();
  final UserService _userService = UserService();
  bool _isSending = false;
  String _selectedCategory = 'geral';

  final _categories = [
    ('geral', 'Dúvida Geral'),
    ('contas', 'Problemas com Conta'),
    ('financas', 'Finanças'),
    ('metas', 'Metas & Tarefas'),
    ('tecnico', 'Problema Técnico'),
    ('sugestao', 'Sugestão'),
    ('outro', 'Outro'),
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isSending) return;

    setState(() => _isSending = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sessão expirada. Faça login novamente.')),
        );
        return;
      }

      // Get user profile info
      String userName = user.displayName ?? 'Utilizador';
      String userEmail = user.email ?? '';
      try {
        final doc = await _userService.getUserProfile(user.uid);
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          userName = data['name'] as String? ?? userName;
          userEmail = data['email'] as String? ?? userEmail;
        }
      } catch (_) {}

      final message = HelpMessage(
        id: '',
        userId: user.uid,
        userName: userName,
        userEmail: userEmail,
        subject: _subjectController.text.trim(),
        message: _messageController.text.trim(),
        category: _selectedCategory,
      );

      await _service.sendMessage(message);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mensagem enviada com sucesso! Entraremos em contacto em breve.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao enviar mensagem: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: scheme.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Enviar Mensagem',
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fale connosco',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: scheme.primary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Envie-nos uma mensagem e responderemos o mais breve possível.',
                  style: TextStyle(
                    color: scheme.onSurface.withValues(alpha: 0.65),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 24),

                // Category
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    filled: true,
                    fillColor: scheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: scheme.onSurface.withValues(alpha: 0.14),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: scheme.onSurface.withValues(alpha: 0.14),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  items: _categories
                      .map((c) => DropdownMenuItem(
                            value: c.$1,
                            child: Text(c.$2),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedCategory = val);
                  },
                ),
                const SizedBox(height: 16),

                // Subject
                TextFormField(
                  controller: _subjectController,
                  decoration: InputDecoration(
                    labelText: 'Assunto',
                    hintText: 'Resumo do problema',
                    filled: true,
                    fillColor: scheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: scheme.onSurface.withValues(alpha: 0.14),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: scheme.onSurface.withValues(alpha: 0.14),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 16),

                // Message
                TextFormField(
                  controller: _messageController,
                  maxLines: 6,
                  decoration: InputDecoration(
                    labelText: 'Mensagem',
                    hintText: 'Descreva o seu problema em detalhe...',
                    filled: true,
                    fillColor: scheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: scheme.onSurface.withValues(alpha: 0.14),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: scheme.onSurface.withValues(alpha: 0.14),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: scheme.primary),
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: 24),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _isSending ? null : _submit,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      _isSending ? 'A enviar...' : 'Enviar Mensagem',
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

