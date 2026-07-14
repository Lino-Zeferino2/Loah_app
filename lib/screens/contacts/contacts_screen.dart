import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/mock/mock_data.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/contact_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_avatar_action.dart';
import '../../widgets/loah_drawer.dart';
import 'add_contact_screen.dart';
import 'widgets/contact_filter_sheet.dart';
import 'widgets/contact_list_tile.dart';
import 'widgets/contact_search_bar.dart';
import 'widgets/favorite_contact_avatar.dart';

/// "Loah - Contatos": a searchable, filterable address book with a
/// horizontal "Favoritos" carousel up top and the remaining contacts
/// grouped alphabetically underneath.
///
/// Reads straight from [MockData.contacts] rather than keeping a local
/// copy, so a contact added via [AddContactScreen] shows up immediately.
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

  String _query = '';
  ContactFilters _filters = const ContactFilters();

  /// Every relationship tag currently in use, so the filter sheet only
  /// ever shows options that actually exist (no empty categories).
  List<String> get _availableRelationships =>
      MockData.contacts.map((c) => c.relationshipTag).toSet().toList()..sort();

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

  List<ContactModel> get _favorites =>
      MockData.contacts.where((c) => c.isFavorite && _passesFilters(c)).toList();

  /// Non-favorite contacts, filtered by search + [_filters] and grouped
  /// by first letter, e.g. {'A': [...], 'B': [...]}.
  Map<String, List<ContactModel>> get _groupedContacts {
    final filtered = MockData.contacts.where((c) => !c.isFavorite && _passesFilters(c)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final grouped = <String, List<ContactModel>>{};
    for (final contact in filtered) {
      grouped.putIfAbsent(contact.initialLetter, () => []).add(contact);
    }
    return grouped;
  }

  Future<void> _addContact() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const AddContactScreen()),
    );
    // AddContactScreen writes straight into MockData.contacts, so a
    // rebuild here is enough to show the newly created contact.
    setState(() {});
  }

  Future<void> _openFilters() async {
    final result = await showModalBottomSheet<ContactFilters>(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.loahColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ContactFilterSheet(
        availableRelationships: _availableRelationships,
        initialFilters: _filters,
      ),
    );
    if (result != null) setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    final nav = LoahNavigationController.of(context);
    final grouped = _groupedContacts;
    final sortedLetters = grouped.keys.toList()..sort();

    return Scaffold(
      drawer: LoahDrawer(currentIndex: nav.currentIndex, onNavigate: nav.navigateTo),
      appBar: const LoahAppBar(title: 'Loah', actions: [LoahAvatarAction()]),
      body: SafeArea(
        child: Center(
          // Keeps the list from stretching edge-to-edge on tablets/
          // foldables while behaving exactly like before on phones.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                ContactSearchBar(
                  onChanged: (v) => setState(() => _query = v),
                  onFilterTap: _openFilters,
                  hasActiveFilters: _filters.isActive,
                ),
                const SizedBox(height: AppSpacing.xl),

                if (_favorites.isNotEmpty) ...[
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
                      itemCount: _favorites.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, i) => FavoriteContactAvatar(
                        contact: _favorites[i],
                        ringColor: _palette[i % _palette.length],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],

                if (grouped.isEmpty && _favorites.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: Text(
                        'Nenhum contato encontrado com esses filtros.',
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
                          onMessage: () {},
                          onCall: () {},
                        ),
                      ),
                    ),


                  ],
                  const SizedBox(height: AppSpacing.md),
                ],
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'contacts_fab',
        onPressed: _addContact,
        child: const Icon(Icons.add),
      ),
    );
  }
}