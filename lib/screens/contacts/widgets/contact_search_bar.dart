import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// "Buscar contatos..." input at the top of the Contatos screen, with
/// an optional trailing filter button (shows a small dot when at least
/// one filter is active).
class ContactSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  const ContactSearchBar({
    super.key,
    this.onChanged,
    this.onFilterTap,
    this.hasActiveFilters = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Buscar contatos...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: colors.cardBackgroundAlt,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: colors.cardBackgroundAlt,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: IconButton(
                  onPressed: onFilterTap,
                  icon: Icon(
                    Icons.tune,
                    size: 20,
                    color: hasActiveFilters ? colors.accentBlue : context.textSecondary,
                  ),
                ),
              ),
              if (hasActiveFilters)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colors.accentBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.cardBackgroundAlt, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }
}