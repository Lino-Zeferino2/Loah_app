import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// "Buscar tarefas..." input with a trailing filter icon button, shown
/// at the top of the Tarefas screen.
class TaskSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  const TaskSearchBar({super.key, this.onChanged, this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Buscar tarefas...',
              prefixIcon: const Icon(Icons.search, size: 20),
              filled: true,
              fillColor: colors.cardBackgroundAlt,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          decoration: BoxDecoration(
            color: colors.cardBackgroundAlt,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            onPressed: onFilterTap,
            icon: const Icon(Icons.tune, size: 20),
          ),
        ),
      ],
    );
  }
}
