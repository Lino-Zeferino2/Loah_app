import '../../models/goal_model.dart';
import '../../models/task_model.dart';

/// Computes a [GoalModel]'s progress, regardless of its
/// [GoalProgressMode]. Keeping this as a pure function (not a field on
/// the model) means the value is never stale — it's always derived
/// fresh from the current task list.
class GoalProgress {
  GoalProgress._();

  /// Progress in the 0..1 range.
  static double of(GoalModel goal, List<TaskModel> allTasks) {
    switch (goal.progressMode) {
      case GoalProgressMode.manualValue:
        return goal.manualProgress;
      case GoalProgressMode.taskChecklist:
        final linked = linkedTasks(goal, allTasks);
        if (linked.isEmpty) return 0;
        final done = linked.where((t) => t.isDone).length;
        return done / linked.length;
    }
  }

  static int percentOf(GoalModel goal, List<TaskModel> allTasks) =>
      (of(goal, allTasks) * 100).round();

  /// All tasks linked to [goal] via [TaskModel.goalId].
  static List<TaskModel> linkedTasks(GoalModel goal, List<TaskModel> allTasks) =>
      allTasks.where((t) => t.goalId == goal.id).toList();
}