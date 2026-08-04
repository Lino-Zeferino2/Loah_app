# TODO — Plano de Implementação

## Tarefa: Testes de widget + Goal de Fundo de Emergência default

### 1. Criar goal de fundo de emergência default quando usuário não tem nenhum
- [ ] `lib/screens/finances/finances_screen.dart`: adicionar criação automática da meta `goal_emergency_fund` quando não existir

### 2. Adicionar testes de widget para telas principais
- [ ] Criar `test/widget_screens_test.dart` com harness de teste (LocaleController, ThemeController, CurrencyController, AppTheme)
- [ ] Adicionar mock HttpOverrides para Image.network
- [ ] Testes Dashboard: BalanceCard, PendingTasksCard, NewItemCard, GoalsSummaryCard, DailyReflectionCard
- [ ] Testes Metas: GoalCard, GoalTermSection
- [ ] Testes Finanças: TransactionListItem, AccountCard, BudgetCard, TotalBalanceCard, AssetCard, RecurringTransactionCard, EmergencyGoalCard
- [ ] Testes Tarefas: TaskListItem
- [ ] Testes Contatos: ContactListTile
- [ ] Testes Notificações: NotificationCard

### 3. Verificação
- [ ] Executar `flutter test` — todos passam
- [ ] Executar `flutter analyze`

### 4. Atualizar TODO.md
- [ ] Marcar item 6 (Fundo de Emergência) como feito
- [ ] Marcar "Adicionar testes de widget para telas principais" como feito
