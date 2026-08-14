import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/theme/app_theme.dart';

const int kMaxRecurringDates = 31;

/// Bottom sheet para selecionar várias datas num calendário (usado na
/// criação de tarefas recorrentes). Retorna a lista de datas escolhidas,
/// ou null se o usuário cancelar.
class MultiDatePickerSheet extends StatefulWidget {
  final List<DateTime> initialDates;

  const MultiDatePickerSheet({super.key, this.initialDates = const []});

  @override
  State<MultiDatePickerSheet> createState() => _MultiDatePickerSheetState();
}

class _MultiDatePickerSheetState extends State<MultiDatePickerSheet> {
  late DateTime _visibleMonth;
  late Set<DateTime> _selected;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
    _selected = widget.initialDates.map(_stripTime).toSet();
  }

  DateTime _stripTime(DateTime d) => DateTime(d.year, d.month, d.day);

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  void _toggleDate(DateTime day) {
    final key = _stripTime(day);
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        if (_selected.length >= kMaxRecurringDates) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocales.of(context)
                  .translate('addTask_limite_datas')
                  .replaceFirst('{max}', '$kMaxRecurringDates')),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
        _selected.add(key);
      }
    });
  }

  List<DateTime?> _buildMonthGrid() {
    final firstDay = DateTime(_visibleMonth.year, _visibleMonth.month, 1);
    final daysInMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1, 0).day;
    // weekday: 1=segunda ... 7=domingo. Queremos grid começando na segunda.
    final leadingBlanks = firstDay.weekday - 1;

    final cells = <DateTime?>[
      for (int i = 0; i < leadingBlanks; i++) null,
      for (int d = 1; d <= daysInMonth; d++) DateTime(_visibleMonth.year, _visibleMonth.month, d),
    ];
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocales.of(context);
    final colors = context.loahColors;
    final cells = _buildMonthGrid();
    final today = _stripTime(DateTime.now());

    const weekdayLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

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
                  loc.translate('addTask_selecionar_datas'),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  '${_selected.length}/$kMaxRecurringDates',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_visibleMonth.month.toString().padLeft(2, '0')}/${_visibleMonth.year}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            Row(
              children: weekdayLabels
                  .map((l) => Expanded(
                        child: Center(
                          child: Text(l, style: Theme.of(context).textTheme.bodySmall),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 4),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: cells.map((day) {
                if (day == null) return const SizedBox.shrink();
                final key = _stripTime(day);
                final isSelected = _selected.contains(key);
                final isPast = key.isBefore(today);

                return Padding(
                  padding: const EdgeInsets.all(2),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(100),
                    onTap: isPast ? null : () => _toggleDate(day),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? colors.accentBlue : Colors.transparent,
                      ),
                      child: Text(
                        '${day.day}',
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : isPast
                                  ? context.textSecondary?.withValues(alpha: 0.4)
                                  : null,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(null),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(loc.translate('addTask_cancelar')),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _selected.isEmpty
                        ? null
                        : () => Navigator.of(context).pop(_selected.toList()..sort()),
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.accentBlue,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(loc.translate('addTask_confirmar')),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}