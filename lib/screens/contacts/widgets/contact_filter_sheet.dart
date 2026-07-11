import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Result of the filter sheet: which relationship tags are checked and
/// whether "somente favoritos" is on. An empty [relationships] set
/// means "no filter" (show every tag).
class ContactFilters {
  final Set<String> relationships;
  final bool favoritesOnly;

  const ContactFilters({this.relationships = const {}, this.favoritesOnly = false});

  bool get isActive => relationships.isNotEmpty || favoritesOnly;

  ContactFilters copyWith({Set<String>? relationships, bool? favoritesOnly}) {
    return ContactFilters(
      relationships: relationships ?? this.relationships,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
    );
  }
}

/// Bottom sheet for filtering the Contatos list: pick one or more
/// relationship types (e.g. "Amigo", "Familiar") and/or restrict to
/// favorites only.
class ContactFilterSheet extends StatefulWidget {
  final List<String> availableRelationships;
  final ContactFilters initialFilters;

  const ContactFilterSheet({
    super.key,
    required this.availableRelationships,
    required this.initialFilters,
  });

  @override
  State<ContactFilterSheet> createState() => _ContactFilterSheetState();
}

class _ContactFilterSheetState extends State<ContactFilterSheet> {
  late Set<String> _relationships = {...widget.initialFilters.relationships};
  late bool _favoritesOnly = widget.initialFilters.favoritesOnly;

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filtrar Contatos',
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (_relationships.isNotEmpty || _favoritesOnly)
                  TextButton(
                    onPressed: () => setState(() {
                      _relationships = {};
                      _favoritesOnly = false;
                    }),
                    child: const Text('Limpar'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Somente favoritos'),
              value: _favoritesOnly,
              activeColor: colors.accentBlue,
              onChanged: (v) => setState(() => _favoritesOnly = v),
            ),
            const SizedBox(height: 8),
            Text(
              'GRAU DE CONEXÃO',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 0.6,
                    color: context.textSecondary,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in widget.availableRelationships)
                  FilterChip(
                    label: Text(tag),
                    selected: _relationships.contains(tag),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _relationships.add(tag);
                      } else {
                        _relationships.remove(tag);
                      }
                    }),
                    selectedColor: colors.accentBlue.withValues(alpha: 0.2),
                    checkmarkColor: colors.accentBlue,
                    labelStyle: TextStyle(
                      color: _relationships.contains(tag) ? colors.accentBlue : null,
                      fontWeight: FontWeight.w600,
                    ),
                    backgroundColor: colors.cardBackgroundAlt,
                    side: BorderSide(
                      color: _relationships.contains(tag) ? colors.accentBlue : colors.border,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(
                  ContactFilters(relationships: _relationships, favoritesOnly: _favoritesOnly),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.accentBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Aplicar Filtros', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}