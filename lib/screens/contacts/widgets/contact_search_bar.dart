import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// "Buscar contatos..." input at the top of the Contatos screen.
class ContactSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const ContactSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return TextField(
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
    );
  }
}