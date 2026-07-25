import '../../models/goal_model.dart';
import '../../models/task_model.dart';

/// Computes a [GoalModel]'s progress, regardless of its
/// [GoalProgressMode]. Keeping this as a pure function (not a field on
/// the model) means the value is never stale — it's always derived
/// fresh from the current task list.
class GoalProgress {
  GoalProgress._();

  /// Progress in the 0..1 range.
  ///
  /// - **taskChecklist** goals: always driven purely by linked tasks
  ///   (done / total).
  /// - **manualValue** goals: driven purely by current/target *unless*
  ///   the goal also has linked tasks (e.g. "Comprar um Carro" with
  ///   milestone tasks) — in that case progress is the average of the
  ///   value-based and task-based progress, so completing tasks moves
  ///   the needle even for a value-tracked goal.
  static double of(GoalModel goal, List<TaskModel> allTasks) {
    final linked = linkedTasks(goal, allTasks);
    final taskProgress =
        linked.isEmpty ? null : linked.where((t) => t.isDone).length / linked.length;

    switch (goal.progressMode) {
      case GoalProgressMode.taskChecklist:
        return taskProgress ?? 0;
      case GoalProgressMode.manualValue:
        final valueProgress = goal.manualProgress;
        if (taskProgress == null) return valueProgress;
        return (valueProgress + taskProgress) / 2;
    }
  }

  static int percentOf(GoalModel goal, List<TaskModel> allTasks) =>
      (of(goal, allTasks) * 100).round();

  /// All tasks linked to [goal] via [TaskModel.goalId].
  static List<TaskModel> linkedTasks(GoalModel goal, List<TaskModel> allTasks) =>
      allTasks.where((t) => t.goalId == goal.id).toList();
}