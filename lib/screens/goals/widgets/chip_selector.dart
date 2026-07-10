import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// One selectable option in a [ChipSelector].
class ChipOption<T> {
  final String label;
  final T value;
  const ChipOption(this.label, this.value);
}

/// A wrap of pill-shaped, single-select chips — used for both
/// "Categoria" and "Prazo" on the Add Goal form. Generic over [T] so it
/// works with plain strings (category) or an enum (GoalTerm).
class ChipSelector<T> extends StatelessWidget {
  final List<ChipOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  const ChipSelector({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.loahColors;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          GestureDetector(
            onTap: () => onChanged(option.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: option.value == selected ? colors.accentBlue : colors.cardBackgroundAlt,
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: option.value == selected ? colors.accentBlue : colors.border,
                ),
              ),
              child: Text(
                option.label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: option.value == selected ? Colors.white : context.textSecondary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}