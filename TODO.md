# TODO - Internacionalização (i18n) dos ecrãs de Tarefas e Metas

## Plano de Trabalho (Tarefas)

- [x] 1. Análise dos ficheiros relevantes concluída
- [x] 2. Plano aprovado

## Edições (Tarefas)

- [x] 3. `lib/core/l10n/app_localizations.dart` - Adicionar chaves de tradução para horizontes de metas, prioridades, status, ecrã add task
- [x] 4. `lib/screens/tasks/add_task_screen.dart` - Corrigir string hardcoded no _delete()
- [x] 5. `lib/screens/tasks/widgets/priority_selector.dart` - Usar AppLocales para labels
- [x] 6. `lib/screens/tasks/widgets/task_list_item.dart` - Usar AppLocales para priority label
- [x] 7. `lib/screens/tasks/task_detail_screen.dart` - Internacionalizar todas as strings
- [x] 8. `lib/screens/tasks/widgets/task_filter_sheet.dart` - Internacionalizar strings
- [x] 9. `lib/screens/tasks/widgets/related_goal_card.dart` - Internacionalizar strings
- [x] 10. `lib/screens/tasks/tasks_screen.dart` - Internacionalizar labels de filtros ativos
- [x] 11. `lib/screens/tasks/widgets/goal_picker_sheet.dart` - Internacionalizar labels

## Edições (Metas)

- [x] 12. `lib/core/l10n/app_localizations.dart` - Adicionar chaves de tradução para ecrãs de Metas
- [x] 13. `lib/screens/goals/goals_screen.dart` - Internacionalizar strings
- [x] 14. `lib/screens/goals/add_goal_screen.dart` - Internacionalizar strings
- [x] 15. `lib/screens/goals/goal_detail_screen.dart` - Internacionalizar strings
- [x] 16. `lib/screens/goals/widgets/goal_term_section.dart` - Internacionalizar labels
- [x] 17. `lib/screens/goals/widgets/goal_card.dart` - Internacionalizar caption
- [x] 18. `lib/screens/dashboard/widgets/goals_summary_card.dart` - Internacionalizar strings

## Verificação

- [x] 19. Executar `flutter analyze` para verificar erros (1 warning: unused import - resolvido)

