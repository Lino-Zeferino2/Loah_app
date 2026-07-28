import 'package:flutter/material.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../models/goal_model.dart';
import '../../../models/task_model.dart';
import '../../../widgets/section_header.dart';
import 'goal_card.dart';

/// Visual identity (icon + color) for each time horizon, used in the
/// section title — e.g. a lightning bolt for "Curto Prazo".
extension GoalTermVisuals on GoalTerm {
  IconData get icon => switch (this) {
        GoalTerm.curtoPrazo => Icons.bolt_rounded,
        GoalTerm.medioPrazo => Icons.calendar_month_outlined,
        GoalTerm.longoPrazo => Icons.stars_rounded,
      };

  Color get color => switch (this) {
        GoalTerm.curtoPrazo => Colors.green,
        GoalTerm.medioPrazo => Colors.deepOrange,
        GoalTerm.longoPrazo => Colors.indigo,
      };

  /// Returns the translated full label using the given AppLocales.
  String localizedLabel(AppLocales loc) => switch (this) {
        GoalTerm.curtoPrazo => loc.translate('goalTerm_curto_prazo'),
        GoalTerm.medioPrazo => loc.translate('goalTerm_medio_prazo'),
        GoalTerm.longoPrazo => loc.translate('goalTerm_longo_prazo'),
      };

  /// Returns the translated horizon hint using the given AppLocales.
  String localizedHorizon(AppLocales loc) => switch (this) {
        GoalTerm.curtoPrazo => loc.translate('goalTerm_horizon_curto_prazo'),
        GoalTerm.medioPrazo => loc.translate('goalTerm_horizon_medio_prazo'),
        GoalTerm.longoPrazo => loc.translate('goalTerm_horizon_longo_prazo'),
      };

  /// Compact form for chip selectors, e.g. the Add Goal form's "Prazo"
  /// section, where the full "Curto Prazo" label wouldn't fit as well.
  String get shortLabel => switch (this) {
        GoalTerm.curtoPrazo => 'Curto',
        GoalTerm.medioPrazo => 'Médio',
        GoalTerm.longoPrazo => 'Longo',
      };
}

/// Groups goals under a time-horizon heading, e.g.
/// "Curto Prazo · Este Mês" with its list of [GoalCard]s.
class GoalTermSection extends StatelessWidget {
  final GoalTerm term;
  final List<GoalModel> goals;
  final List<TaskModel> allTasks;
  final ValueChanged<GoalModel> onGoalTap;

  /// Icon used inside each [GoalCard]'s badge (defaults to a flag).
  final IconData cardIcon;

  const GoalTermSection({
    super.key,
    required this.term,
    required this.goals,
    required this.allTasks,
    required this.onGoalTap,
    this.cardIcon = Icons.flag_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocales.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: term.localizedLabel(loc),
          icon: term.icon,
          iconColor: term.color,
          trailing: Text(
            term.localizedHorizon(loc),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: 10),
        for (final goal in goals) ...[
          GoalCard(
            goal: goal,
            allTasks: allTasks,
            icon: cardIcon,
            onTap: () => onGoalTap(goal),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}
