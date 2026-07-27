# Plano de Melhorias — Loah App

## 🔴 1. Deploy das Cloud Functions (CRÍTICO)
- [x] Executar `firebase deploy --only functions`
- [x] Verificar deploy no Firebase Console ✅ (Todas as 8 funções deployed com sucesso)
  - sendNotificationOnWrite
  - checkOverdueContacts (scheduler 08:00)
  - checkUpcomingTasks (scheduler 07:00/19:00)
  - checkRecurringBills (scheduler 06:00)
  - checkOverBudget (scheduler 1st/15th)
  - checkGoalMilestones (scheduler 10:00)
  - onSupportMessageCreated
  - onSupportMessageReplied

## 🟡 2. Firebase Analytics & Crashlytics (RECOMENDADO)
- [x] Adicionar `firebase_analytics` ao pubspec.yaml
- [x] Adicionar `firebase_crashlytics` ao pubspec.yaml
- [x] Executar `flutter pub get`
- [x] Criar `lib/core/services/analytics_service.dart`
- [x] Configurar Analytics + Crashlytics no `main.dart`
- [x] Configurar Error Widget para Crashlytics (FlutterError.onError + PlatformDispatcher)

## 🟡 3. Modo Offline (Firestore Persistence)
- [x] Ativar `persistenceEnabled` no Firestore no `main.dart`
- [x] Configurado com `cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED`

## 🟡 4. Testes Automatizados
- [x] Melhorar `test/widget_test.dart` — smoke test, modelos AppNotification/ContactModel, CurrencyFormatter, goal progress validation
- [x] Verificar com `flutter test` ✅ (17/17 testes passaram)

## 🐛 Bugfix: Crashlytics `type 'String' is

