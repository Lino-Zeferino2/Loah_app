import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loah_app/core/theme/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/services/contact_service.dart';
import '../../core/theme/app_theme.dart';
import '../../models/contact_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_avatar_action.dart';
import '../../widgets/loah_drawer.dart';
import 'add_contact_screen.dart';
import 'contact_detail_screen.dart';
import 'widgets/contact_filter_sheet.dart';
import 'widgets/contact_list_tile.dart';
import 'widgets/contact_search_bar.dart';
import 'widgets/favorite_contact_avatar.dart';

/// "Loah - Contatos": a searchable, filterable address book with a
/// horizontal "Favoritos" carousel up top and the remaining contacts
/// grouped alphabetically underneath.
///
/// Reads contacts from Firestore via [ContactService] stream.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  // A fixed color rotation for avatar rings/fallback initials — keeps
  // things visually varied without needing a color field per contact.
  static const _palette = [
    Colors.cyan,
    Colors.deepPurple,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.pinkAccent,
  ];

  final ContactService _contactService = ContactService();

  String _query = '';
  ContactFilters _filters = const ContactFilters();

  /// Converte um [DocumentSnapshot] do Firestore para [ContactModel].
  ContactModel _docToContact(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ContactModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'],
      phone: data['phone'],
      relationshipTag: data['relationshipTag'] ?? 'Amigo',
      avatarUrl: data['avatarUrl'],
      isFavorite: data['isFavorite'] ?? false,
      desiredContactFrequencyDays: data['desiredContactFrequencyDays'],
      interactions: _parseInteractions(data['interactions']),
    );
  }

  List<ContactInteraction> _parseInteractions(dynamic raw) {
    if (raw == null || raw is! List) return [];
    return raw.map((e) {
      final map = e as Map<String, dynamic>;
      return ContactInteraction(
        date: (map['date'] as Timestamp).toDate(),
        type: InteractionType.values.firstWhere(
          (t) => t.name == map['type'],
          orElse: () => InteractionType.other,
        ),
        note: map['note'],
      );
    }).toList();
  }

  /// Alterna o estado de favorito de um contacto no Firestore.
  Future<void> _toggleFavorite(ContactModel contact) async {
    final updated = contact.copyWith(isFavorite: !contact.isFavorite);
    try {
      await _contactService.updateContact(updated);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar favorito: $e')),
      );
    }
  }

  /// Constrói a lista de contactos a partir da stream do Firestore.
  Widget _buildContactsList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if (snapshot.hasError) {
      return Center(
        child: Text('Erro ao carregar contatos: ${snapshot.error}'),
      );
    }

    final allContacts = snapshot.data?.docs
            .map((doc) => _docToContact(doc))
            .toList() ??
        [];

    final favorites =
        allContacts.where((c) => c.isFavorite && _passesFilters(c)).toList();

    final filtered = allContacts
        .where((c) => !c.isFavorite && _passesFilters(c))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final grouped = <String, List<ContactModel>>{};
    for (final contact in filtered) {
      grouped.putIfAbsent(contact.initialLetter, () => []).add(contact);
    }
    final sortedLetters = grouped.keys.toList()..sort();

    final colors = context.loahColors;

    if (allContacts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            'Nenhum contato ainda. Adicione um novo contato!',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        ContactSearchBar(
          onChanged: (v) => setState(() => _query = v),
          onFilterTap: _openFilters,
          hasActiveFilters: _filters.isActive,
        ),
        const SizedBox(height: AppSpacing.xl),

        if (favorites.isNotEmpty) ...[
          Text(
            'FAVORITOS',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 0.6,
                  color: context.textSecondary,
                ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) => FavoriteContactAvatar(
                contact: favorites[i],
                ringColor: _palette[i % _palette.length],
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ContactDetailScreen(
                        contact: favorites[i],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],

        if (grouped.isEmpty && favorites.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 40),
            child: Center(
              child: Text(
                _query.isNotEmpty || _filters.isActive
                    ? 'Nenhum contato encontrado com esses filtros.'
                    : 'Nenhum contato ainda. Adicione um novo contato!',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ),

        for (final letter in sortedLetters) ...[
          Text(
            letter,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: colors.accentBlue,
            ),
          ),
          const SizedBox(height: 4),
          for (var i = 0; i < grouped[letter]!.length; i++) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: colors.border.withValues(alpha: 0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: ContactListTile(
                  contact: grouped[letter]![i],
                  avatarColor: _palette[i % _palette.length],
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ContactDetailScreen(
                          contact: grouped[letter]![i],
                        ),
                      ),
                    );
                  },
                  onToggleFavorite: () =>
                      _toggleFavorite(grouped[letter]![i]),
                  onMessage: () {},
                  onCall: () {},
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }

  bool _passesFilters(ContactModel c) {
    if (_filters.favoritesOnly && !c.isFavorite) return false;
    if (_filters.relationships.isNotEmpty &&
        !_filters.relationships.contains(c.relationshipTag)) {
      return false;
    }
    if (_query.isNotEmpty && !c.name.toLowerCase().contains(_query.toLowerCase())) {
      return false;
    }
    return true;
  }


  Future<void> _addContact() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddContactScreen()),
    );
    // The Firestore stream will automatically update the list.
  }

  Future<void> _openFilters() async {
    // Build available relationships from current stream data
    final snapshot = await _contactService.getContactsStream().first;
    final allContacts = snapshot.docs.map((doc) => _docToContact(doc)).toList();
    final availableRelationships =
        allContacts.map((c) => c.relationshipTag).toSet().toList()..sort();

    if (!mounted) return;
    final result = await showModalBottomSheet<ContactFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ContactFilterSheet(
        availableRelationships: availableRelationships,
        initialFilters: _filters,
      ),
    );
    if (result != null) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final nav = LoahNavigationController.of(context);

    return Scaffold(
      drawer: LoahDrawer(currentIndex: nav.currentIndex, onNavigate: nav.navigateTo),
      appBar: const LoahAppBar(title: 'Loah', actions: [LoahAvatarAction()]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: StreamBuilder<QuerySnapshot>(
              stream: _contactService.getContactsStream(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return _buildContactsList(snapshot);
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        heroTag: 'contacts_fab',
        onPressed: _addContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}
