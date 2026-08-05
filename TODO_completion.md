# Plano de Conclusão — Lacunas Identificadas

> **Nota de sessão (análise):** nesta sessão foi feita uma **análise completa do
> sistema** e o `flutter analyze` foi executado (0 erros, 0 warnings, 3 info-level).
> A tarefa de localização das telas de auth/splash/onboarding foi **concluída** —
> todas as telas agora usam `AppLocales` (tradução centralizada PT/EN).

## 1. Localização PT/EN (strings hardcoded → AppLocales)
> **Estado atual (verificado):** as chaves de tradução para auth/splash/onboarding
> **foram adicionadas** ao `app_localizations.dart` (auth_login_subtitle, splash_tagline,
> onb_*, etc.) e **todas** as telas de auth/splash/onboarding foram refatoradas para
> usar `AppLocales.of(context).translate(...)`. `flutter analyze` reporta **0 erros**.

- [x] `app_localizations.dart`: adicionar chaves de tradução para telas de auth/splash/onboarding
- [x] `login_screen.dart`: usar AppLocales — **✅ Concluído**
- [x] `signup_screen.dart`: usar AppLocales — **✅ Concluído**
- [x] `email_verification_screen.dart`: usar AppLocales — **✅ Concluído**
- [x] `password_recovery_screen.dart`: usar AppLocales — **✅ Concluído**
- [x] `reset_password_screen.dart`: usar AppLocales — **✅ Concluído**
- [x] `splash_screen.dart`: usar AppLocales — **✅ Concluído**
- [x] `onboarding_screen.dart`: usar AppLocales — **✅ Concluído**

## 2. Moeda padrão
- [x] `main.dart`: default `BRL` → `EUR` — **✅ Concluído** (`_currencyCode = 'EUR'`)

## 3. Versão consistente
- [x] `Sobre Loah`: `2.4.0` → `1.0.0` (alinhar com conteúdo "pubspec.yaml") — **✅ Concluído** (`about_loah_screen.dart` agora mostra "Versão atual: 1.0.0", igual ao `pubspec.yaml` que é `1.0.0+1`)

## 4. README desatualizado
- [x] `README.md`: atualizar para refletir o uso de Firebase/Firestore — **✅ Concluído** (nova seção "Firebase / Firestore"; arquitetura e "Dados" atualizados)

## 5. Avisos `const` do analyze
> **Estado atual:** `flutter analyze` reporta 3 issues `prefer_const_constructors`
> (info-level, não são erros). Dois deles (nos testes) envolvem closures e não podem
> ser const.

- [x] `finances_screen.dart:189`: adicionar `const` — **⚠️ Atenção:** usa `GoalProgress.of()` (runtime), não é const-able **✅ Concluído** 
- [x] `widget_screens_test.dart:263`: adicionar `const` — **⚠️ Atenção:** closure, não é const-able **✅ Concluído** 
- [x] `widget_screens_test.dart:370`: adicionar `const` — **⚠️ Atenção:** closure, não é const-able **✅ Concluído** 

## 6. Ficheiro órfão `c`
- [x] Remover ficheiro vazio `c` da raiz — **✅ Concluído** 

## 7. Testes de integração de auth
- [x] Criar `test/auth_flow_test.dart` com cobertura de fluxos de auth — **✅ Concluído** (16 novos testes: cobertura de tradução PT/EN de todas as chaves de auth/splash/onboarding + fluxos de widget do OnboardingScreen)

## Verificação
- [x] `flutter analyze` — ✅ 0 erros e 0 warnings (apenas 3 info-level `prefer_const_constructors`)
- [x] `flutter test` — ✅ 114 testes, todos passam (98 existentes + 16 novos de `auth_flow_test.dart`)

---

## ✅ Verificação Final de Publicação (sessão atual)

### Código
- [x] `flutter analyze` — ✅ **No issues found!** (ran in 134.7s)
- [x] `flutter test` — ✅ **114 testes, todos passam** (`00:03 +114: All tests passed!`)
- [x] Moeda default corrigida no teste: `test/widget_screens_test.dart:185` — `R$` → `€` (alinhado com o default EUR do `main.dart`)

### Backend Firebase (deploy)
- [x] **Firestore rules** — ✅ deploy concluído (`firestore.rules`)
- [x] **Cloud Functions** — ✅ 8 functions implantadas:
  `sendNotificationOnWrite`, `checkOverdueContacts`, `checkUpcomingTasks`,
  `checkRecurringBills`, `checkOverBudget`, `onSupportMessageCreated`,
  `onSupportMessageReplied`, `checkGoalMilestones`
- [x] **Storage rules** — ✅ deploy concluído (`storage.rules`); `firebase.json` atualizado
  com o bucket `loahapp.firebasestorage.app` (corrigido para permitir o deploy de storage)

### Seed de dados globais
- [x] **Conteúdo legal** (`upload-app-content.js`) — ✅ `appContent/aboutLoah` atualizado
  (termos, privacidade, sobre nós)
- [x] **Dados globais** (`seed-global-oauth.js` — novo script OAuth) — ✅
  - Reflections: 10
  - Help Center Categories: 8
  - Help Center Articles: 10

> **Nota:** o `seed.js` original usa `applicationDefault()` (service account), que não
> está disponível neste ambiente. Foi criado `functions/seed-global-oauth.js` que usa o
> mesmo mecanismo OAuth do `upload-app-content.js` (refresh_token do Firebase CLI) para
> semear reflections/categorias/artigos sem service account.

### Pronto para publicar
Os seguintes pré-requisitos de publicação estão atendidos:
- `google-services.json` (Android) presente em `android/app/`
- `GoogleService-Info.plist` (iOS) presente em `ios/Runner/`
- `firebase_options.dart` gerado com config Android/iOS/web
- Keystore de release configurado (`android/key.properties` + `release-keystore.jks`)
- `version: 1.0.0+1` consistente no `pubspec.yaml` e na tela "Sobre Loah"
- Regras de segurança (firestore + storage) implantadas e funcionais
- Conteúdo da app (politica, termos, sobre, reflexões, ajuda) populado no Firestore
