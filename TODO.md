# Notification System Fixes

## Progress

- [x] Analyze code and identify issues
- [x] Plan fixes
- [x] **Fix 1: Navigate to correct screens on notification tap**
  - [x] Tasks → TaskDetailScreen via relatedId
  - [x] Goals → GoalDetailScreen via relatedId
  - [x] Contacts → ContactDetailScreen via relatedId
  - [x] Finance (non-recurring) → BudgetsScreen
  - [x] System → just marks as read
  - [x] All taps mark notification as read
- [x] **Fix 2: Add filter to notifications screen**
  - [x] Filter chips: Todas, Não lidas, Contactos, Tarefas, Metas, Finanças, Sistema
  - [x] Visual distinction for read/unread notifications
- [x] **Fix 3: Clean up duplicate classes in currency_formatter.dart**
- [x] **Fix 4: Add currency translations to app_localizations.dart**
- [x] **Fix 5: Update drawer imports for currency controller**

