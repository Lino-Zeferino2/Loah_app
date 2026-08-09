# Fix: Crash on welcome/email-verification screen for new users

## Root cause
`lib/screens/auth/email_verification_screen.dart` called `AppLocales.of(context)`
inside `initState()`, which internally calls
`context.dependOnInheritedWidgetOfExactType<LocaleController>()`. Flutter forbids
this in `initState`, throwing:
> "dependOnInheritedWidgetOfExactType() was called before ... initState() completed"

This is the first screen a NEW user sees after registering, so every new user
hits the crash and must force-close/reopen to get in.

## Steps
- [x] Investigate and confirm root cause
- [x] Get user approval on plan
- [x] Move `AppLocales.of(context)` initialization from `initState` into
      `didChangeDependencies` in `email_verification_screen.dart`
- [x] Run `flutter analyze` to confirm no regressions (No issues found)
- [x] Run the existing widget tests relating to the auth flow (All 16 passed)
