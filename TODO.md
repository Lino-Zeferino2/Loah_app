# TODO: Localize remaining transaction labels (categories + relative dates)

## Steps
- [x] 1. Plan approved by user
- [x] 2. Add `relative_hoje` key and capitalize `relative_ontem` in `app_localizations.dart`
- [x] 3. Add `translateRelativeDate(TransactionModel)` helper method to `app_localizations.dart`
- [x] 4. Update `transaction_filter_sheet.dart` to translate category names in filter chips
- [x] 5. Update `transaction_list_item.dart` to use translated relative date labels
- [x] 6. Run `flutter analyze` to verify (no issues found)

