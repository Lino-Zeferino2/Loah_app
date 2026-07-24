# Migration Tasks — Mock to Firebase

## ✅ Step 1: Create `TaskService` (`lib/core/services/task_service.dart`)
- [x] Pattern identical to `ContactService`
- [x] Collection: `/users/{userId}/tasks/{taskId}`
- [x] Methods: `getTasksStream()`, `addTask()`, `updateTask()`, `deleteTask()`, `getTask()`
- [x] Map `TaskModel` ↔ Firestore document

## ✅ Step 2: Create `GoalService` (`lib/core/services/goal_service.dart`)
- [x] Same pattern as `ContactService`
- [x] Collection: `/users/{userId}/goals/{goalId}`
- [x] Methods: `getGoalsStream()`, `addGoal()`, `updateGoal()`, `deleteGoal()`, `getGoal()`
- [x] Map `GoalModel` ↔ Firestore document

## ✅ Step 3: Update `tasks_screen.dart`
- [x] Replace `MockData.tasks` with `TaskService` stream + `StreamBuilder`
- [x] Add **filter modal** with: Status, Priority, Date filters
- [x] Professional modal with selectable chips

## ✅ Step 4: Update `add_task_screen.dart`
- [x] Replace `MockData.tasks` writes with `TaskService.addTask()` / `.updateTask()` / `.deleteTask()`
- [x] Replace `MockData.goals` reads with `GoalService`

## ✅ Step 5: Update `task_detail_screen.dart`
- [x] Read/write tasks via `TaskService`
- [x] Read goals via `GoalService`

## ✅ Step 6: Update `goal_detail_screen.dart`
- [x] Read/write tasks via `TaskService`
- [x] Read/write goals via `GoalService`

## ✅ Step 7: Update `goals_screen.dart`
- [x] Replace `MockData.goals` with `GoalService`
- [x] Replace `MockData.tasks` reads with `TaskService`

## ✅ Step 8: Update `dashboard_screen.dart`
- [x] Replace `MockData.tasks` with `TaskService`
- [x] Replace `MockData.goals` with `GoalService`
- [x] Added RefreshIndicator for pull-to-refresh

## ✅ Step 9: Update `goal_picker_sheet.dart`
- [x] Read goals from Firestore via `GoalService` instead of `MockData`

## ✅ Step 10: Create `task_filter_sheet.dart`
- [x] Create filter modal widget for tasks screen
- [x] Filters: Status (pendente/emProgresso/concluida), Priority (alta/media/baixa), Date range

## ✅ Step 11: Update `add_goal_screen.dart`
- [x] Replace `MockData.goals` writes with `GoalService.addGoal()` / `.updateGoal()`
- [x] Added loading state and error handling
