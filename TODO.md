# TODO: Internacionalizar (i18n) os ecrãs de Contactos

## Concluído ✅

- [x] 1. `lib/core/l10n/app_localizations.dart` — Adicionar ~80 novas chaves de tradução + método `translateRelationshipTag()`
- [x] 2. `lib/screens/contacts/contacts_screen.dart` — Substituir strings por `AppLocales.of(context).translate('contacts_...')`
- [x] 3. `lib/screens/contacts/add_contact_screen.dart` — Substituir strings por `AppLocales.of(context).translate('addContact_...')`
- [x] 4. `lib/screens/contacts/contact_detail_screen.dart` — Substituir strings por `AppLocales.of(context).translate('contactDetail_...' | 'interaction_...')`
- [x] 5. `lib/screens/contacts/widgets/contact_filter_sheet.dart` — Substituir strings + relationship tags traduzidos
- [x] 6. `lib/screens/contacts/widgets/contact_search_bar.dart` — Substituir hint por `contactSearch_hint`
- [x] 7. `lib/screens/contacts/widgets/country_code_picker_sheet.dart` — Substituir strings por `countryPicker_...`
- [x] 8. `lib/screens/contacts/widgets/contact_list_tile.dart` — Traduzir `relationshipTag` via `translateRelationshipTag()`
- [x] 9. `lib/screens/contacts/widgets/favorite_contact_avatar.dart` — Traduzir `relationshipTag` via `translateRelationshipTag()`
- [x] 10. `flutter analyze` — Sem erros encontrados ✅
