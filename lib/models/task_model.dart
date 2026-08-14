enum TaskPriority { alta, media, baixa }

/// Where a task stands. [TaskModel.isDone] still drives "concluída"
/// everywhere else in the app (it's the field every checkbox toggles),
/// so [status] is mainly there to distinguish "not started yet" from
/// "already being worked on" for an *incomplete* task — see
/// [TaskModel.effectiveStatus].
enum TaskStatus { pendente, emProgresso, concluida }

/// A to-do item shown on the Dashboard and Tarefas screens.
class TaskModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? tag;
  final String? dueLabel;
  final TaskPriority? priority;
  final bool isDone;
  final String? goalId;
  final DateTime? completedAt;
  final String? description;
  final DateTime? dueDate;
  final DateTime? createdAt;
  final TaskStatus? status;

  /// Se definido, esta tarefa faz parte de um grupo de tarefas criadas
  /// juntas (recorrência por datas múltiplas). Cada ocorrência é um
  /// documento independente — editar/apagar uma não afeta as outras.
  /// [seriesId] serve só para identificação futura (ex.: mostrar um
  /// ícone de "faz parte de uma série").
  final String? seriesId;

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
    this.seriesId,
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

  /// Formata data curta com tradução dos meses (ex: "15 Out").
  /// Usa [monthTranslator] para obter o nome do mês abreviado no idioma atual.
  static String shortDateLocale(DateTime date, String Function(int month) monthTranslator) =>
      '${date.day} ${monthTranslator(date.month - 1)}';

  /// Formata data longa com tradução dos meses (ex: "15 de Outubro, 2024").
  static String longDateLocale(DateTime date, String Function(int month) monthTranslator) =>
      '${date.day} de ${monthTranslator(date.month - 1)}, ${date.year}';
}