import 'package:flutter/material.dart';
import '../../core/mock/mock_data.dart';
import '../../core/theme/app_theme.dart';
import '../../models/contact_model.dart';
import '../../widgets/goal_image.dart';
import '../../widgets/loah_app_bar_simple.dart';
import '../../widgets/loah_card.dart';
import 'add_contact_screen.dart';

/// "Loah - Detalhes do Contato": profile info, an overdue banner when
/// it's been too long since the last touchpoint, quick buttons to log
/// a new interaction, and the full interaction history.
class ContactDetailScreen extends StatefulWidget {
  final ContactModel contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late ContactModel _contact = widget.contact;

  static const _monthAbbrev = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  void _logInteraction(InteractionType type) {
    setState(() {
      final updated = _contact.copyWith(
        interactions: [
          ..._contact.interactions,
          ContactInteraction(date: DateTime.now(), type: type),
        ],
      );
      _contact = updated;
      final index = MockData.contacts.indexWhere((c) => c.id == updated.id);
      if (index != -1) MockData.contacts[index] = updated;
    });
  }

  Future<void> _editContact() async {
    final updated = await Navigator.of(context).push<ContactModel?>(
      MaterialPageRoute(builder: (_) => AddContactScreen(existingContact: _contact)),
    );
    if (updated != null) setState(() => _contact = updated);
  }

  Future<void> _pickFrequency() async {
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
              title: const Text('Sem lembrete'),
              onTap: () => Navigator.of(sheetContext).pop(-1), // -1 = "clear"
            ),
            ListTile(
              title: const Text('Toda semana'),
              onTap: () => Navigator.of(sheetContext).pop(7),
            ),
            ListTile(
              title: const Text('A cada 15 dias'),
              onTap: () => Navigator.of(sheetContext).pop(15),
            ),
            ListTile(
              title: const Text('Todo mês'),
              onTap: () => Navigator.of(sheetContext).pop(30),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (result == null) return;

    setState(() {
      final updated = result == -1
          ? _contact.copyWith(clearFrequency: true)
          : _contact.copyWith(desiredContactFrequencyDays: result);
      _contact = updated;
      final index = MockData.contacts.indexWhere((c) => c.id == updated.id);
      if (index != -1) MockData.contacts[index] = updated;
    });
  }

  String _frequencyLabel(int? days) => switch (days) {
        null => 'Sem lembrete',
        7 => 'Toda semana',
        15 => 'A cada 15 dias',
        30 => 'Todo mês',
        _ => 'A cada $days dias',
      };

  String _relativeLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'há ${diff.inHours}h';
    if (diff.inDays == 1) return 'ontem';
    if (diff.inDays < 7) return 'há ${diff.inDays} dias';
    return '${date.day} ${_monthAbbrev[date.month - 1]}';
  }

  IconData _interactionIcon(InteractionType type) => switch (type) {
        InteractionType.call => Icons.call_outlined,
        InteractionType.message => Icons.chat_bubble_outline,
        InteractionType.meeting => Icons.people_outline,
        InteractionType.other => Icons.more_horiz,
      };

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final contact = _contact;
    final sortedInteractions = [...contact.interactions]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: LoahAppBarSimple(title: contact.name),
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
                      contact.relationshipTag,
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
                      label: const Text('Editar Contato'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                        'Já se passaram ${contact.daysSinceLastContact} dias desde o último '
                        'contato. Que tal ligar pra ${contact.name.split(' ').first}?',
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
                      Text('ÚLTIMO CONTATO', style: Theme.of(context).textTheme.labelSmall),
                      Text(
                        contact.lastContactedAt == null
                            ? 'Nenhum ainda'
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
              'Registrar Contato',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _QuickLogButton(
                    icon: Icons.call_outlined,
                    label: 'Ligação',
                    onTap: () => _logInteraction(InteractionType.call),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickLogButton(
                    icon: Icons.chat_bubble_outline,
                    label: 'Mensagem',
                    onTap: () => _logInteraction(InteractionType.message),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _QuickLogButton(
                    icon: Icons.people_outline,
                    label: 'Encontro',
                    onTap: () => _logInteraction(InteractionType.meeting),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Text(
              'Histórico',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            if (sortedInteractions.isEmpty)
              Text(
                'Nenhuma interação registrada ainda.',
                style: Theme.of(context).textTheme.bodySmall,
              )
            else
              for (final interaction in sortedInteractions)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: LoahCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Row(
                      children: [
                        Icon(_interactionIcon(interaction.type), size: 18, color: colors.accentBlue),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(interaction.type.label,
                              style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                        Text(
                          _relativeLabel(interaction.date),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
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