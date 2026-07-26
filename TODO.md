# TODO: Notificações de Suporte (SMS Admin/User)

## Objective
Implement notification sending when:
1. A user sends a support message → notify admin(s)
2. Admin replies to a support message → notify the user

## Steps

- [x] Step 0: Analyze codebase (HelpCenterService, functions/index.js, notification infrastructure)
- [x] Step 1: Create/edit `functions/index.js` - Add Cloud Function `onSupportMessageCreated` (trigger on `helpCenterMessages` onCreate → notify admins)
- [x] Step 2: Create/edit `functions/index.js` - Add Cloud Function `onSupportMessageReplied` (trigger on `helpCenterMessages` onUpdate when `adminReply` changes → notify user)
- [x] Step 3: **Deploy the functions** - Run `firebase deploy --only functions` when ready

## Additional Improvements

### Step 4: Navegação com dados completos do Firestore via Notificação Push
- [x] Melhorar `_navigateFromNotification` no `RootShell` em `main.dart` para buscar dados completos (ContactModel, TaskModel, GoalModel) do Firestore antes de navegar para as telas de detalhes, em vez de criar modelos parciais.

### Step 5: Notificação "todas as tarefas concluídas" ao marcar tarefas como feitas
- [x] Adicionar chamada a `NotificationScheduler().checkAllTasksDone()` em `_toggle` do `tasks_screen.dart`
- [x] Adicionar chamada a `NotificationScheduler().checkAllTasksDone()` em `_toggleDone` do `task_detail_screen.dart`

