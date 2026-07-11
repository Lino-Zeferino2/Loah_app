import 'package:flutter/material.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../models/contact_model.dart';
import '../../widgets/loah_app_bar.dart';
import '../../widgets/loah_avatar_action.dart';
import '../../widgets/loah_drawer.dart';
import 'widgets/contact_list_tile.dart';
import 'widgets/contact_search_bar.dart';
import 'widgets/favorite_contact_avatar.dart';

/// "Loah - Contatos": a searchable address book with a horizontal
/// "Favoritos" carousel up top and the remaining contacts grouped
/// alphabetically underneath.
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  static const _contacts = [
    ContactModel(name: 'Keeloah Ferreira', relationshipTag: 'Namorada', isFavorite: true),
    ContactModel(name: 'Bruno Alves', relationshipTag: 'Amigo', isFavorite: true),
    ContactModel(name: 'Carlos Souza', relationshipTag: 'Pai', isFavorite: true),
    ContactModel(name: 'Diana Ferreira', relationshipTag: 'Mãe', isFavorite: true),
    ContactModel(
      name: 'Adriana Silva',
      email: 'adriana.silva@loah.app',
      relationshipTag: 'Colega',
    ),
    ContactModel(
      name: 'Andre Martins',
      phone: '+55 11 98877-6655',
      relationshipTag: 'Conhecido',
    ),
    ContactModel(
      name: 'Beatriz Gomes',
      email: 'beatriz@empresa.com.br',
      relationshipTag: 'Amiga',
    ),
    ContactModel(
      name: 'Caio Castro',
      email: 'caio.analyst@tech.io',
      relationshipTag: 'Familiar',
    ),
    ContactModel(
      name: 'Clarice Lispector',
      email: 'clarice@letras.org',
      relationshipTag: 'Conhecida',
    ),
  ];

  static const _palette = [
    Colors.cyan,
    Colors.deepPurple,
    Colors.teal,
    Colors.green,
    Colors.orange,
    Colors.pinkAccent,
  ];

  String _query = '';

  List<ContactModel> get _favorites =>
      _contacts.where((c) => c.isFavorite).toList();

  Map<String, List<ContactModel>> get _groupedContacts {
    final filtered = _contacts.where((c) {
      if (c.isFavorite) return false;
      if (_query.isEmpty) return true;
      return c.name.toLowerCase().contains(_query.toLowerCase());
    }).toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    final grouped = <String, List<ContactModel>>{};
    for (final contact in filtered) {
      grouped.putIfAbsent(contact.initialLetter, () => []).add(contact);
    }
    return grouped;
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
                ContactSearchBar(onChanged: (v) => setState(() => _query = v)),
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
                    height: 110,
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
                    ContactListTile(
                      contact: grouped[letter]![i],
                      avatarColor: _palette[i % _palette.length],
                      onMessage: () {},
                      onCall: () {},
                    ),
                    if (i != grouped[letter]!.length - 1)
                      Divider(
                        height: 1,
                        thickness: 1,
                        indent: 56, // aligns with the text, past the avatar
                        color: colors.border.withValues(alpha: 0.6),
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
      onPressed: () {},
      child: const Icon(Icons.add),
    ),
    );
  }
}