import 'package:flutter/material.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/services/contact_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/call_utils.dart';
import '../../models/contact_model.dart';
import '../../widgets/goal_image.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import 'add_contact_screen.dart';

/// "Loah - Detalhes do Contato": profile info, an overdue banner when
/// it's been too long since the last touchpoint, quick buttons to log
/// a new interaction, the full interaction history, and a favorite
/// toggle with confirmation dialog.
class ContactDetailScreen extends StatefulWidget {
  final ContactModel contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late ContactModel _contact = widget.contact;

  final ContactService _contactService = ContactService();

  /// Alterna o estado de favorito com confirmação por AlertDialog.
  Future<void> _toggleFavorite() async {
    final loc = AppLocales.of(context);
    final newStatus = !_contact.isFavorite;

    final titulo = newStatus
        ? loc.translate('contactDetail_favoritar_titulo')
        : loc.translate('contactDetail_desfavoritar_titulo');
    final msgPrefix = newStatus
        ? loc.translate('contactDetail_favoritar_msg')
        : loc.translate('contactDetail_desfavoritar_msg');
    final msgSuffix = newStatus
        ? loc.translate('contactDetail_aos_favoritos')
        : loc.translate('contactDetail_dos_favoritos');
    final mensagem = '$msgPrefix ${_contact.name.split(' ').first} $msgSuffix';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.translate('contactDetail_cancelar')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.translate('contactDetail_confirmar')),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final updated = _contact.copyWith(isFavorite: newStatus);
    try {
      await _contactService.updateContact(updated);
      if (!mounted) return;
      setState(() => _contact = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('contactDetail_erro_favorito')}$e')),
      );
    }
  }

  Future<void> _logInteraction(InteractionType type, {String? note}) async {
    final loc = AppLocales.of(context);
    final updated = _contact.copyWith(
      interactions: [
        ..._contact.interactions,
        ContactInteraction(date: DateTime.now(), type: type, note: note),
      ],
    );
    try {
      await _contactService.updateContact(updated);
      if (!mounted) return;
      setState(() => _contact = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('contactDetail_erro_interacao')}$e')),
      );
    }
  }

  Future<void> _deleteInteraction(int index) async {
    final loc = AppLocales.of(context);
    final updatedInteractions = List<ContactInteraction>.from(_contact.interactions)
      ..removeAt(index);
    final updated = _contact.copyWith(interactions: updatedInteractions);
    try {
      await _contactService.updateContact(updated);
      if (!mounted) return;
      setState(() => _contact = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('contactDetail_erro_remover_interacao')}$e')),
      );
    }
  }

  Future<void> _deleteContact() async {
    final loc = AppLocales.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.translate('contactDetail_remover_contato_titulo')),
        content: Text('${loc.translate('contactDetail_remover_contato_msg')} ${_contact.name.split(' ').first} ${loc.translate('contactDetail_remover_contato_suffix')}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.translate('contactDetail_cancelar')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(loc.translate('contactDetail_remover')),
          ),
        ],
      ),
    );
    if (confirm != true) return;

try {
      // Apaga também a foto de perfil do Storage (se existir) para
      // não deixar ficheiros órfãos depois de remover o contacto.
      if (_contact.avatarUrl != null) {
        await _contactService.deleteAvatar(_contact.avatarUrl);
      }
      await _contactService.deleteContact(_contact.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${loc.translate('contactDetail_erro_remover_contato')}$e')),
      );
    }
  }

  Future<void> _editContact() async {
    final updated = await Navigator.of(context).push<ContactModel?>(
      MaterialPageRoute(builder: (_) => AddContactScreen(existingContact: _contact)),
    );
    if (updated != null) setState(() => _contact = updated);
  }

  Future<void> _pickFrequency() async {
    final loc = AppLocales.of(context);
    final result = await showModalBottomSheet<int?>(
      context: context,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(loc.translate('contactDetail_sem_lembrete')),
              onTap: () => Navigator.of(sheetContext).pop(-1),
            ),
            ListTile(
              title: Text(loc.translate('contactDetail_toda_semana')),
              onTap: () => Navigator.of(sheetContext).pop(7),
            ),
            ListTile(
              title: Text(loc.translate('contactDetail_15_dias')),
              onTap: () => Navigator.of(sheetContext).pop(15),
            ),
            ListTile(
              title: Text(loc.translate('contactDetail_todo_mes')),
              onTap: () => Navigator.of(sheetContext).pop(30),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (result == null) return;

    final updated = result == -1
        ? _contact.copyWith(clearFrequency: true)
        : _contact.copyWith(desiredContactFrequencyDays: result);

    try {
      await _contactService.updateContact(updated);
      if (!mounted) return;
      setState(() => _contact = updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocales.of(context).translate('contactDetail_erro_frequencia')}$e')),
      );
    }
  }

  String _frequencyLabel(int? days) {
    final loc = AppLocales.of(context);
    return switch (days) {
      null => loc.translate('contactDetail_sem_lembrete'),
      7 => loc.translate('contactDetail_toda_semana'),
      15 => loc.translate('contactDetail_15_dias'),
      30 => loc.translate('contactDetail_todo_mes'),
      _ => '${loc.translate('contactDetail_a_cada')} $days ${loc.translate('contactDetail_dias')}',
    };
  }

  String _relativeLabel(DateTime date) {
    final loc = AppLocales.of(context);
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${loc.translate('relative_ha')} ${diff.inMinutes} ${loc.translate('relative_min')}';
    if (diff.inHours < 24) return '${loc.translate('relative_ha')} ${diff.inHours}h';
    if (diff.inDays == 1) return loc.translate('relative_ontem');
    if (diff.inDays < 7) return '${loc.translate('relative_ha')} ${diff.inDays} ${loc.translate('relative_dias')}';
    return '${date.day} ${loc.translate('mes_${_monthAbbrevIdx(date.month)}')}';
  }

  String _monthAbbrevIdx(int month) {
    const months = ['jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez'];
    return months[month - 1];
  }

  IconData _interactionIcon(InteractionType type, {String? note}) {
    if (type == InteractionType.other && note != null) {
      return switch (note) {
        'Presencial' => Icons.person_pin,
        'Redes Sociais' => Icons.alternate_email,
        'Email' => Icons.email_outlined,
        'Presente' => Icons.card_giftcard,
        _ => Icons.more_horiz,
      };
    }
    return switch (type) {
        InteractionType.call => Icons.call_outlined,
        InteractionType.message => Icons.chat_bubble_outline,
        InteractionType.meeting => Icons.people_outline,
        InteractionType.other => Icons.more_horiz,
      };
  }

  Future<void> _showOtherInteractionSheet() async {
    final loc = AppLocales.of(context);
    final colors = context.loahColors;
    final result = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: colors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Text(
              loc.translate('contactDetail_tipo_interacao'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            _InteractionOptionTile(
              icon: Icons.person_pin,
              label: loc.translate('contactDetail_presencial'),
              subtitle: loc.translate('contactDetail_presencial_sub'),
              onTap: () => Navigator.of(sheetContext).pop('Presencial'),
            ),
            _InteractionOptionTile(
              icon: Icons.alternate_email,
              label: loc.translate('contactDetail_redes_sociais'),
              subtitle: loc.translate('contactDetail_redes_sociais_sub'),
              onTap: () => Navigator.of(sheetContext).pop('Redes Sociais'),
            ),
            _InteractionOptionTile(
              icon: Icons.email_outlined,
              label: loc.translate('contactDetail_email_interacao'),
              subtitle: loc.translate('contactDetail_email_interacao_sub'),
              onTap: () => Navigator.of(sheetContext).pop('Email'),
            ),
            _InteractionOptionTile(
              icon: Icons.card_giftcard,
              label: loc.translate('contactDetail_presente'),
              subtitle: loc.translate('contactDetail_presente_sub'),
              onTap: () => Navigator.of(sheetContext).pop('Presente'),
            ),
            _InteractionOptionTile(
              icon: Icons.more_horiz,
              label: loc.translate('contactDetail_outro'),
              subtitle: loc.translate('contactDetail_outro_sub'),
              onTap: () => Navigator.of(sheetContext).pop('Outro'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (result == null) return;
    await _logInteraction(InteractionType.other, note: result);
  }

  /// Abre o modal de chamada e regista a interação apenas se o usuário
  /// selecionar uma opção (WhatsApp ou Chamada).
  Future<void> _onCallButtonPressed() async {
    if (_contact.phone == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocales.of(context).translate('contactDetail_sem_telefone'))),
      );
      return;
    }

    bool interagiu = false;
    if (!mounted) return;
    try {
      interagiu = await showCallOptions(
        context,
        _contact.phone!,
        contactName: _contact.name.split(' ').first,
      );
    } catch (e) {
      if (!mounted) return;
      debugPrint('call_utils: Erro em showCallOptions: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocales.of(context).translate('common_erro')}: $e')),
      );
      return;
    }

    if (!mounted || !interagiu) return;
    await _logInteraction(InteractionType.call);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocales.of(context);
    final colors = context.loahColors;
    final contact = _contact;
    final sortedInteractions = [...contact.interactions]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: LoahAppBarSimple(
        title: contact.name,
        actions: [
          IconButton(
            tooltip: contact.isFavorite
                ? loc.translate('contactDetail_desfavoritar_titulo')
                : loc.translate('contactDetail_favoritar_titulo'),
            onPressed: _toggleFavorite,
            icon: Icon(
              contact.isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: contact.isFavorite ? Colors.amber : null,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            LoahCard(
              child: Column(
                children: [
                  ClipOval(
                    child: Container(
                      width: 84,
                      height: 84,
                      color: colors.cardBackgroundAlt,
                      child: contact.avatarUrl == null
                          ? Center(
                              child: Text(
                                contact.initials,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 24),
                              ),
                            )
                          : GoalImage(path: contact.avatarUrl!),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    contact.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: colors.accentBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Text(
                      loc.translateRelationshipTag(contact.relationshipTag),
                      style: TextStyle(color: colors.accentBlue, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (contact.email != null || contact.phone != null) ...[
                    const SizedBox(height: 12),
                    if (contact.email != null)
                      Text(contact.email!, style: Theme.of(context).textTheme.bodyMedium),
                    if (contact.phone != null)
                      Text(contact.phone!, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _editContact,
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(loc.translate('contactDetail_editar_contato')),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _deleteContact,
                      icon: Icon(Icons.delete_outline, size: 16, color: colors.negative),
                      label: Text(loc.translate('contactDetail_remover_contato_btn'), style: TextStyle(color: colors.negative)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        side: BorderSide(color: colors.negative.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            if (contact.isOverdue)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colors.negative.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: colors.negative.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.notifications_active_outlined, color: colors.negative, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        // CORRIGIDO: antes mostrava sempre a contagem de dias
                        // (incluindo o valor sentinela 999 para "nunca
                        // contactado"), o que não faz sentido para um contacto
                        // recém-criado. Agora distingue os dois casos.
                        contact.lastContactedAt == null
                            ? '${loc.translate('contactDetail_atrasado_prefix_nunca')} ${contact.name.split(' ').first}?'
                            : '${loc.translate('contactDetail_atrasado_prefix')} ${contact.daysSinceLastContact} ${loc.translate('contactDetail_atrasado_dias')} '
                              '${loc.translate('contactDetail_atrasado_meio')} ${contact.name.split(' ').first}?',
                        style: TextStyle(color: colors.negative, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            LoahCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(loc.translate('contactDetail_ultimo_contato'), style: Theme.of(context).textTheme.labelSmall),
                      Text(
                        contact.lastContactedAt == null
                            ? loc.translate('contactDetail_nenhum_ainda')
                            : _relativeLabel(contact.lastContactedAt!),
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: _pickFrequency,
                    child: Row(
                      children: [
                        Text(
                          _frequencyLabel(contact.desiredContactFrequencyDays),
                          style: TextStyle(color: colors.accentBlue, fontWeight: FontWeight.w600),
                        ),
                        Icon(Icons.chevron_right, size: 18, color: colors.accentBlue),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              loc.translate('contactDetail_registrar_contato'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickLogButton(
                    icon: Icons.call_outlined,
                    label: loc.translate('contactDetail_ligacao'),
                    onTap: _onCallButtonPressed,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickLogButton(
                    icon: Icons.chat_bubble_outline,
                    label: loc.translate('contactDetail_mensagem'),
                    onTap: () async {
                      if (_contact.phone != null) {
                        final interagiu = await showMessageOptions(
                          context,
                          _contact.phone!,
                          contactName: _contact.name.split(' ').first,
                        );
                        if (!mounted || !interagiu) return;
                        await _logInteraction(InteractionType.message);
                      } else {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(loc.translate('contactDetail_sem_telefone'))),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickLogButton(
                    icon: Icons.more_horiz,
                    label: loc.translate('contactDetail_outro'),
                    onTap: _showOtherInteractionSheet,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              loc.translate('contactDetail_historico'),
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (sortedInteractions.isEmpty)
              Text(
                loc.translate('contactDetail_sem_interacoes'),
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              for (final interaction in sortedInteractions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Dismissible(
                    key: ValueKey('${interaction.date.millisecondsSinceEpoch}-${interaction.type.name}-${sortedInteractions.indexOf(interaction)}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade400,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.white, size: 22),
                    ),
                    confirmDismiss: (direction) async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: Text(loc.translate('contactDetail_remover_interacao_titulo')),
                          content: Text(loc.translate('contactDetail_remover_interacao_msg')),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: Text(loc.translate('contactDetail_cancelar')),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: TextButton.styleFrom(foregroundColor: Colors.red),
                              child: Text(loc.translate('contactDetail_remover')),
                            ),
                          ],
                        ),
                      );
                      return confirm ?? false;
                    },
                    onDismissed: (direction) {
                      final originalIndex = _contact.interactions.indexOf(interaction);
                      if (originalIndex != -1) {
                        _deleteInteraction(originalIndex);
                      }
                    },
                    child: LoahCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            _interactionIcon(interaction.type, note: interaction.note),
                            size: 18,
                            color: colors.accentBlue,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              interaction.type == InteractionType.other && interaction.note != null
                                  ? interaction.note!
                                  : loc.translate('interaction_${interaction.type.name}'),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                          Text(
                            _relativeLabel(interaction.date),
                            style: Theme.of(context).textTheme.bodySmall,
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
}

class _InteractionOptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _InteractionOptionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return ListTile(
      leading: Icon(icon, color: colors.accentBlue),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: Icon(Icons.chevron_right, color: colors.accentBlue, size: 18),
      onTap: onTap,
    );
  }
}

class _QuickLogButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickLogButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return Material(
      color: colors.accentBlue.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon, color: colors.accentBlue, size: 20),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(color: colors.accentBlue, fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

