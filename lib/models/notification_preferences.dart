/// Preferências de notificação do utilizador, guardadas em
/// users/{uid}/settings/notificationPreferences.
class NotificationPreferences {
  final bool contactsEnabled;
  final bool tasksEnabled;
  final bool goalsEnabled;
  final bool financeEnabled;
  final bool systemEnabled;

  /// Quantas horas de antecedência para avisar de uma tarefa a vencer
  /// (equivalente ao "avisar-me X antes" do Google Calendar).
  final int taskReminderLeadHours;

  const NotificationPreferences({
    this.contactsEnabled = true,
    this.tasksEnabled = true,
    this.goalsEnabled = true,
    this.financeEnabled = true,
    this.systemEnabled = true,
    this.taskReminderLeadHours = 24,
  });

  factory NotificationPreferences.fromMap(Map<String, dynamic> data) {
    return NotificationPreferences(
      contactsEnabled: data['contactsEnabled'] as bool? ?? true,
      tasksEnabled: data['tasksEnabled'] as bool? ?? true,
      goalsEnabled: data['goalsEnabled'] as bool? ?? true,
      financeEnabled: data['financeEnabled'] as bool? ?? true,
      systemEnabled: data['systemEnabled'] as bool? ?? true,
      taskReminderLeadHours: data['taskReminderLeadHours'] as int? ?? 24,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'contactsEnabled': contactsEnabled,
      'tasksEnabled': tasksEnabled,
      'goalsEnabled': goalsEnabled,
      'financeEnabled': financeEnabled,
      'systemEnabled': systemEnabled,
      'taskReminderLeadHours': taskReminderLeadHours,
    };
  }

  NotificationPreferences copyWith({
    bool? contactsEnabled,
    bool? tasksEnabled,
    bool? goalsEnabled,
    bool? financeEnabled,
    bool? systemEnabled,
    int? taskReminderLeadHours,
  }) {
    return NotificationPreferences(
      contactsEnabled: contactsEnabled ?? this.contactsEnabled,
      tasksEnabled: tasksEnabled ?? this.tasksEnabled,
      goalsEnabled: goalsEnabled ?? this.goalsEnabled,
      financeEnabled: financeEnabled ?? this.financeEnabled,
      systemEnabled: systemEnabled ?? this.systemEnabled,
      taskReminderLeadHours:
          taskReminderLeadHours ?? this.taskReminderLeadHours,
    );
  }
}