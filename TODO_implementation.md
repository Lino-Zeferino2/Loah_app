# Plano de Implementação — Keystore + Deep Linking

## Tarefa 1 — Keystore de produção Android
- [x] Corrigir `android/app/build.gradle.kts` (storeFile → rootProject.file)
- [x] Rodar `flutter build apk --release` e validar assinatura
- [x] Atualizar TODO.md

## Tarefa 2 — Deep linking para recovery de senha
- [x] Adicionar `app_links` ao pubspec.yaml
- [x] Criar `lib/core/services/deep_link_service.dart`
- [x] Criar `lib/screens/auth/reset_password_screen.dart`
- [x] Atualizar `lib/core/services/auth_service.dart`
- [x] Atualizar `lib/main.dart`
- [x] Android: intent-filter no AndroidManifest.xml
- [x] iOS: CFBundleURLTypes no Info.plist
- [x] Atualizar TODO.md

## Tarefa 3 — Follow-up
- [x] `flutter pub get`
- [x] `flutter analyze`
- [x] `flutter build apk --release` (✅ SUCESSO, APK assinado)

## Notas finais
- R8: a dependência `com.google.android.play:core:1.10.3` causou conflito de classes
  duplicadas com `core-common:2.0.3`; a solução definitiva foram as regras `-dontwarn`
  adicionadas a `android/app/proguard-rules.pro`.
- `flutter test` não foi executado nesta sessão (fora do âmbito desta tarefa).
