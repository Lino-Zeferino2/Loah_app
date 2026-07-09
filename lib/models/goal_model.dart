import 'package:flutter/material.dart';

enum GoalTerm { curtoPrazo, medioPrazo, longoPrazo }

extension GoalTermLabel on GoalTerm {
  String get label => switch (this) {
        GoalTerm.curtoPrazo => 'Curto Prazo',
        GoalTerm.medioPrazo => 'Médio Prazo',
        GoalTerm.longoPrazo => 'Longo Prazo',
      };

  String get horizon => switch (this) {
        GoalTerm.curtoPrazo => 'Este Mês',
        GoalTerm.medioPrazo => 'Este Ano',
        GoalTerm.longoPrazo => '2+ Anos',
      };
}

/// How a goal's progress is determined.
enum GoalProgressMode {
  /// Progress = current / target (e.g. "R$ 4.250 / R$ 5.000").
  manualValue,

  /// Progress = (done tasks linked to this goal) / (total linked tasks).
  taskChecklist,
}

/// A savings/personal goal, e.g. "Reserva de Emergência" or "Eurotrip 2024".
class GoalModel {
  /// Stable identifier — used to link [TaskModel.goalId] to this goal.
  /// String on purpose: maps directly to a Firestore document ID later.
  final String id;

  final String title;
  final String category;
  final GoalTerm term;
  final GoalProgressMode progressMode;

  /// Only used when [progressMode] is [GoalProgressMode.manualValue].
  final double? current;
  final double? target;

  final String? imageAsset;

  /// Longer explanatory text shown in the detail screen (e.g. "Meta
  /// para adquirir um veículo seminovo para facilitar a locomoção...").
  /// Separate from [category], which stays a short chip label.
  final String? description;

  /// Target date shown as "Dezembro 2024" in the detail screen header.
  final DateTime? targetDate;

  /// Color used for this goal's progress bar (each goal gets its own
  /// accent, e.g. amber for savings, blue for reading, green for study).
  final Color progressColor;

  /// Short caption shown below the bar, e.g. "Faltam R$ 2.400,00" or
  /// "Módulo 2 de 8". Falls back to a generic "Faltam X%" if omitted.
  final String? remainingLabel;

  const GoalModel({
    required this.id,
    required this.title,
    required this.category,
    required this.term,
    this.progressMode = GoalProgressMode.manualValue,
    this.current,
    this.target,
    this.imageAsset,
    this.description,
    this.targetDate,
    this.progressColor = Colors.blue,
    this.remainingLabel,
  });

  /// Progress for [GoalProgressMode.manualValue] goals only. Checklist
  /// goals must use [GoalProgress.of] (in `goal_progress.dart`) instead,
  /// since that needs the full task list to compute from.
  double get manualProgress {
    if (target == null || target == 0) return 0;
    return ((current ?? 0) / target!).clamp(0, 1);
  }

  int get manualProgressPercent => (manualProgress * 100).round();

  static const _monthNames = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  /// e.g. "Dezembro 2024". Null if [targetDate] wasn't set.
  String? get targetDateLabel {
    final date = targetDate;
    if (date == null) return null;
    return '${_monthNames[date.month - 1]} ${date.year}';
  }
}