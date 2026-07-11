enum TaskPriority { alta, media, baixa }

extension TaskPriorityLabel on TaskPriority {
  String get label => switch (this) {
        TaskPriority.alta => 'Alta Prioridade',
        TaskPriority.media => 'Média Prioridade',
        TaskPriority.baixa => 'Baixa Prioridade',
      };

  /// Short form used in compact UI, e.g. the priority selector on the
  /// Add Task screen ("Baixa" / "Média" / "Alta").
  String get shortLabel => switch (this) {
        TaskPriority.alta => 'Alta',
        TaskPriority.media => 'Média',
        TaskPriority.baixa => 'Baixa',
      };
}

/// Where a task stands. [TaskModel.isDone] still drives "concluída"
/// everywhere else in the app (it's the field every checkbox toggles),
/// so [status] is mainly there to distinguish "not started yet" from
/// "already being worked on" for an *incomplete* task — see
/// [TaskModel.effectiveStatus].
enum TaskStatus { pendente, emProgresso, concluida }

extension TaskStatusLabel on TaskStatus {
  String get label => switch (this) {
        TaskStatus.pendente => 'Não Iniciada',
        TaskStatus.emProgresso => 'Em Progresso',
        TaskStatus.concluida => 'Concluída',
      };
}

/// A to-do item shown on the Dashboard and Tarefas screens.
class TaskModel {
  /// Stable identifier — maps to a Firestore document ID later.
  final String id;

  final String title;
  final String? subtitle;
  final String? tag;
  final String? dueLabel;
  final TaskPriority? priority;
  final bool isDone;

  /// If set, this task counts toward a [GoalModel] with
  /// `progressMode == GoalProgressMode.taskChecklist` and the same id.
  final String? goalId;

  /// When the task was marked done — shown as "Concluído em 15 Out" in
  /// the Goal Detail screen. Set automatically by [copyWith] when
  /// [isDone] flips to true; cleared when flipped back to false.
  final DateTime? completedAt;

  /// Longer free-text notes, e.g. "Detalhes importantes para esta
  /// etapa..." — shown on the Add/Edit Task form and the Task Detail
  /// screen. Separate from [subtitle], which stays a short metadata
  /// line (e.g. "Hoje, 17:00") used in compact list rows.
  final String? description;

  /// The actual due date, used for sorting/reminders. [dueLabel] is
  /// still what's displayed in list rows (e.g. "Hoje", "Amanhã") — set
  /// it explicitly for those relative labels, or derive a short date
  /// string from [dueDate] via [TaskModel.shortDate] when creating a
  /// task from a raw date picker value.
  final DateTime? dueDate;

  /// When the task itself was created — shown as "Criada em 18 de
  /// Outubro, 2024" on the Task Detail screen.
  final DateTime? createdAt;

  /// Explicit status for an *incomplete* task (pendente vs em
  /// progresso). Ignored once [isDone] is true — see [effectiveStatus].
  final TaskStatus? status;

  const TaskModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.tag,
    this.dueLabel,
    this.priority,
    this.isDone = false,
    this.goalId,
    this.completedAt,
    this.description,
    this.dueDate,
    this.createdAt,
    this.status,
  });

  /// The status actually shown in the UI: [isDone] always wins
  /// ("Concluída"), otherwise falls back to [status] (defaulting to
  /// "Não Iniciada" if it was never set explicitly).
  TaskStatus get effectiveStatus {
    if (isDone) return TaskStatus.concluida;
    return status ?? TaskStatus.pendente;
  }

  TaskModel copyWith({
    bool? isDone,
    String? title,
    String? description,
    DateTime? dueDate,
    String? dueLabel,
    TaskPriority? priority,
    String? goalId,
    TaskStatus? status,
  }) {
    final newIsDone = isDone ?? this.isDone;
    return TaskModel(
      id: id,
      title: title ?? this.title,
      subtitle: subtitle,
      tag: tag,
      dueLabel: dueLabel ?? this.dueLabel,
      priority: priority ?? this.priority,
      isDone: newIsDone,
      goalId: goalId ?? this.goalId,
      completedAt: newIsDone
          ? (completedAt ?? DateTime.now())
          : null, // cleared if un-checked
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  static const _monthAbbrev = [
    'Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez',
  ];

  static const _monthFull = [
    'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro',
  ];

  /// e.g. "15 Out" — used to turn a raw [DateTime] (from a date picker)
  /// into the short display format used across the app.
  static String shortDate(DateTime date) => '${date.day} ${_monthAbbrev[date.month - 1]}';

  /// e.g. "18 de Outubro, 2024" — used for the longer labels on the
  /// Task Detail screen ("Criada em..." / "Data de Entrega").
  static String longDate(DateTime date) =>
      '${date.day} de ${_monthFull[date.month - 1]}, ${date.year}';

  /// e.g. "Concluído em 15 Out". Null if not done or no timestamp.
  String? get completedLabel {
    final date = completedAt;
    if (!isDone || date == null) return null;
    return 'Concluído em ${shortDate(date)}';
  }

  /// e.g. "Criada em 18 de Outubro, 2024". Null if [createdAt] wasn't set.
  String? get createdAtLongLabel => createdAt == null ? null : 'Criada em ${longDate(createdAt!)}';

  /// e.g. "18 de Outubro, 2024". Null if [dueDate] wasn't set.
  String? get dueDateLongLabel => dueDate == null ? null : longDate(dueDate!);
}