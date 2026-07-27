# TODO: Internacionalizar (i18n) os ecrãs de Contactos

## Progresso

- [x] 1. `lib/core/l10n/app_localizations.dart` — Adicionar novas chaves de tradução para contactos ✅
- [x] 2. `lib/models/contact_model.dart` — Remover strings hardcoded do InteractionTypeLabel ✅
- [x] 3. `lib/screens/contacts/contacts_screen.dart` — Substituir strings por traduções ✅
- [x] 4. `lib/screens/contacts/add_contact_screen.dart` — Substituir strings por traduções ✅
- [x] 5. `lib/screens/contacts/contact_detail_screen.dart` — Substituir strings por traduções ✅
- [x] 6. `lib/screens/contacts/widgets/contact_filter_sheet.dart` — Substituir strings por traduções ✅
- [x] 7. `lib/screens/contacts/widgets/contact_search_bar.dart` — Substituir hint por tradução ✅
- [x] 8. `lib/screens/contacts/widgets/country_code_picker_sheet.dart` — Substituir strings por traduções ✅
- [x] 9. `lib/screens/contacts/widgets/contact_list_tile.dart` — Substituir relationshipTag por tradução ✅
- [x] 10. `lib/screens/contacts/widgets/favorite_contact_avatar.dart` — Substituir relationshipTag por tradução ✅
- [x] 11. Executar `flutter analyze` — 0 erros, apenas 6 informações pré-existentes ✅

## Concluído ✅
Todas as strings visíveis nos ecrãs de contactos usam agora `AppLocales.of(context).translate(...)` para suportar português e inglês.
