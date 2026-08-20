import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/services/help_center_service.dart';
import 'package:loah_app/models/help_center_models.dart';
import '../../core/l10n/app_localizations.dart';

/// Screen where users can view their own support messages,
/// see admin replies, and send follow-up messages.
class MyMessagesScreen extends StatefulWidget {
  const MyMessagesScreen({super.key});

  @override
  State<MyMessagesScreen> createState() => _MyMessagesScreenState();
}

class _MyMessagesScreenState extends State<MyMessagesScreen> {
  final HelpCenterService _service = HelpCenterService();
  List<HelpMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final messages = await _service.getUserMessages(user.uid);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('MyMessages - Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openMessageDetail(HelpMessage message) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _MessageDetailScreen(
          message: message,
          service: _service,
          onFollowUpSent: _loadMessages,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocales.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: scheme.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          loc.translate('myMsgs_titulo'),
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _messages.isEmpty
                ? _buildEmptyState(theme, scheme, loc)
                : RefreshIndicator(
                    onRefresh: _loadMessages,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      itemCount: _messages.length,
                      itemBuilder: (context, index) {
                        final msg = _messages[index];
                        return _MessageListTile(
                          message: msg,
                          onTap: () => _openMessageDetail(msg),
                        );
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, ColorScheme scheme, AppLocales loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined,
              size: 64, color: scheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            loc.translate('myMsgs_vazio_titulo'),
            style: TextStyle(color: scheme.onSurface.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 8),
          Text(
            loc.translate('myMsgs_vazio_sub'),
            style: TextStyle(
              color: scheme.onSurface.withValues(alpha: 0.4),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageListTile extends StatelessWidget {
  final HelpMessage message;
  final VoidCallback onTap;

  const _MessageListTile({required this.message, required this.onTap});

  String _statusLabel(HelpMessageStatus status, AppLocales loc) {
    switch (status) {
      case HelpMessageStatus.pendente:
        return loc.translate('myMsgs_status_pendente');
      case HelpMessageStatus.emAndamento:
        return loc.translate('myMsgs_status_andamento');
      case HelpMessageStatus.resolvido:
        return loc.translate('myMsgs_status_resolvido');
    }
  }

  Color _statusColor(HelpMessageStatus status) {
    switch (status) {
      case HelpMessageStatus.pendente:
        return Colors.orange;
      case HelpMessageStatus.emAndamento:
        return Colors.blue;
      case HelpMessageStatus.resolvido:
        return Colors.green;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocales.of(context);
    final border = scheme.onSurface.withValues(alpha: 0.10);
    final hasReply =
        message.adminReply != null && message.adminReply!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      // Não traduzido: é o assunto escrito pelo utilizador.
                      message.subject,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _statusColor(message.status)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _statusLabel(message.status, loc),
                      style: TextStyle(
                        color: _statusColor(message.status),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                // Não traduzido: é a mensagem escrita pelo utilizador.
                message.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: scheme.onSurface.withValues(alpha: 0.55),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    _formatDate(message.createdAt),
                    style: TextStyle(
                      color: scheme.onSurface.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                  if (hasReply) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.reply,
                        size: 12,
                        color: scheme.primary.withValues(alpha: 0.6)),
                    const SizedBox(width: 2),
                    Text(
                      loc.translate('myMsgs_respondida'),
                      style: TextStyle(
                        color: scheme.primary.withValues(alpha: 0.6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const Spacer(),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: scheme.onSurface.withValues(alpha: 0.3),
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Full-screen detail view for a user's message thread.
class _MessageDetailScreen extends StatefulWidget {
  final HelpMessage message;
  final HelpCenterService service;
  final VoidCallback onFollowUpSent;

  const _MessageDetailScreen({
    required this.message,
    required this.service,
    required this.onFollowUpSent,
  });

  @override
  State<_MessageDetailScreen> createState() => _MessageDetailScreenState();
}

class _MessageDetailScreenState extends State<_MessageDetailScreen> {
  final _replyController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _sendFollowUp() async {
    final loc = AppLocales.of(context);
    final text = _replyController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    try {
      await widget.service.addUserFollowUp(widget.message.id, text);
      widget.onFollowUpSent();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('myMsgs_sucesso')),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${loc.translate('myMsgs_erro')}$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  Widget _buildMessageBubble({
    required String text,
    required String label,
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    final theme = Theme.of(context);

    return Container(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.85,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              // Não traduzido: bolhas mostram texto escrito por
              // utilizador ou admin, no idioma em que foi escrito.
              text,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final loc = AppLocales.of(context);
    final msg = widget.message;
    final hasAdminReply = msg.adminReply != null && msg.adminReply!.isNotEmpty;
    final hasFollowUp = msg.userFollowUp != null && msg.userFollowUp!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: scheme.primary),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          // Não traduzido: assunto escrito pelo utilizador.
          msg.subject,
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 16,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              switch (msg.status) {
                HelpMessageStatus.pendente =>
                  loc.translate('myMsgs_status_pendente').toUpperCase(),
                HelpMessageStatus.emAndamento =>
                  loc.translate('myMsgs_status_andamento').toUpperCase(),
                HelpMessageStatus.resolvido =>
                  loc.translate('myMsgs_status_resolvido').toUpperCase(),
              },
              style: TextStyle(
                color: scheme.primary,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User's original message
              _buildMessageBubble(
                text: msg.message,
                label: loc.translate('myMsgs_minha_mensagem'),
                color: scheme.primary,
                icon: Icons.person_outline_rounded,
                alignment: Alignment.centerLeft,
              ),

              // Admin reply (if any)
              if (hasAdminReply)
                _buildMessageBubble(
                  text: msg.adminReply!,
                  label: loc.translate('myMsgs_resposta_suporte'),
                  color: Colors.green,
                  icon: Icons.support_agent_outlined,
                  alignment: Alignment.centerRight,
                ),

              // User follow-up (if any)
              if (hasFollowUp)
                _buildMessageBubble(
                  text: msg.userFollowUp!,
                  label: loc.translate('myMsgs_meu_seguimento'),
                  color: scheme.primary,
                  icon: Icons.reply_rounded,
                  alignment: Alignment.centerLeft,
                ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Reply field
              Text(
                loc.translate('myMsgs_responder_label'),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _replyController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: loc.translate('myMsgs_escrever_resposta'),
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
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSending ? null : _sendFollowUp,
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
                    _isSending
                        ? loc.translate('myMsgs_enviando')
                        : loc.translate('myMsgs_enviar_resposta'),
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
    );
  }
}