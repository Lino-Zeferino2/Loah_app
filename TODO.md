# 🚀 Loah — Checklist de Lançamento

> **Status atual:** ~85% pronto — Core funcional completo, falta configuração de publicação

---

## 🔴 CRÍTICO — Resolver ANTES de publicar (bloqueante)

### 1. ✅ Assinatura de Release Android
- [x] Criar keystore de release: `android/release-keystore.jks`
- [x] Criar `android/key.properties` com caminho, senha e alias
- [x] Atualizar `android/app/build.gradle.kts`:
  - Adicionado `signingConfigs { create("release") { ... } }`
  - Trocar `signingConfig = signingConfigs.getByName("debug")` para `signingConfig = signingConfigs.getByName("release")`
  - Ativado `isMinifyEnabled = true` e `isShrinkResources = true`
  - Adicionado `proguard-rules.pro`
- [x] Criar `android/app/proguard-rules.pro`
- [x] Adicionar `key.properties` e `release-keystore.jks` ao `.gitignore`

### 2. ✅ SHA-1 do Release para Firebase Console
- [x] SHA-1 obtido: `3D:79:C5:68:40:EF:02:FA:A9:3F:8B:1D:8A:E4:A6:73:27:46:50:19`
- [x] **Ação manual:** Adicionar SHA-1 no Firebase Console → Project Settings → Android App
- [x] **Importante:** sem SHA-1 de release, o Google Sign-In não funciona em produção

### 3. Configurar "Sign in with Apple"
- [ ] Criar App ID no Apple Developer Portal
- [ ] Criar Service ID para "Sign in with Apple"
- [ ] Configurar Return URL no Firebase Console → Authentication → Apple
- [ ] Verificar se o capability está ativo no Xcode

### 4. Ícone do App
- [ ] Criar ícone personalizado em todos os tamanhos:
  - Android: `android/app/src/main/res/mipmap-*` (hdpi, mdpi, xhdpi, xxhdpi, xxxhdpi)
  - iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- [ ] Substituir o ícone default do Flutter

### 5. Nome do App
- [ ] **Android:** `android/app/src/main/AndroidManifest.xml` → `android:label="Loah"`
- [ ] **iOS:** `ios/Runner/Info.plist` → `CFBundleDisplayName` = "Loah"
- [ ] **iOS:** `ios/Runner/Info.plist` → `CFBundleName` = "Loah" (sem espaços)

### 6. ⚠️ Verificação de Email — Não implementada
- [ ] **`lib/core/services/auth_service.dart`** — Adicionar método:
  ```dart
  Future<void> sendEmailVerification() async {
    final user = _auth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
  ```
- [ ] **`lib/screens/auth/signup_screen.dart`** — Após criar conta:
  - Chamar `sendEmailVerification()`
  - Navegar para ecrã "Verifique seu email" (em vez de ir direto para Onboarding)
- [ ] **Criar ecrã `EmailVerificationScreen`**:
  - Mensagem: "Enviamos um email de verificação para [email]"
  - Botão: "Reenviar email"
  - Botão: "Já verifiquei — Continuar"
  - Verificar `user.reload()` + `user.emailVerified` antes de avançar
- [ ] **`lib/screens/splash/splash_screen.dart`** — Verificar `user.emailVerified`:
  - Se `user.emailVerified == false` → redirecionar para `EmailVerificationScreen`
  - Se `user.emailVerified == true` → acesso normal ao `RootShell`
- [ ] **`lib/screens/auth/login_screen.dart`** — Verificar na autenticação:
  - Se `user.emailVerified == false` → redirecionar para `EmailVerificationScreen`

---

## 🟡 IMPORTANTE — Fazer antes do lançamento

### 7. Testes
- [ ] **Testes de widget** — Criar testes para widgets principais (LoahBottomNav, LoahDrawer, BalanceCard, GoalCard, TaskCard, etc.)
- [ ] **Testes de integração** — Testar fluxos completos (cadastro → login → criar transação → ver dashboard)
- [ ] **Testes de golden** — Capturar screenshots de referência para detetar regressões visuais
- [ ] **Testes de serviço** — Mockar Firebase e testar AuthService, FinanceService, TaskService, etc.

### 8. Versão dinâmica no Drawer
- [ ] `lib/widgets/loah_drawer.dart` — Substituir `'Loah v2.4.0'` por:
  ```dart
  final version = 'v${const String.fromEnvironment('APP_VERSION', defaultValue: '1.0.0')}';
  ```
  OU ler do `pubspec.yaml` via `PackageInfo.fromPlatform()`

### 9. Screenshots para as Lojas
- [ ] Capturar screenshots das telas principais:
  - Dashboard, Finanças, Metas, Tarefas, Contactos, Perfil
- [ ] Google Play: 2 screenshots por tela (telefone + tablet)
- [ ] App Store: 3 tamanhos (6.5", 5.5", iPad Pro)

### 10. Descrições para as Lojas
- [ ] Google Play: título (30 car.), descrição curta (80 car.), descrição longa (4000 car.)
- [ ] App Store: título (30 car.), subtítulo (30 car.), descrição (4000 car.)
- [ ] Incluir keywords para ASO (app store optimization)

---

## 🟢 SUGESTÕES — Pós-lançamento

### 11. Limpeza
- [ ] Apagar ficheiro `c` na raiz do projeto (parece lixo)
- [ ] Verificar `analysis_options.yaml` e ajustar regras de lint

### 12. CI/CD Pipeline
- [ ] Configurar GitHub Actions ou Codemagic:
  - `flutter analyze` em cada PR
  - `flutter test` em cada PR
  - Build Android + iOS automático
  - Deploy para Firebase App Distribution (testers)
- [ ] Configurar Fastlane para deploy automático nas lojas

### 13. Analytics nas Telas
- [ ] Adicionar `AnalyticsService().logScreenView()` em todas as telas principais:
  - Dashboard, Finanças, Metas, Tarefas, Contactos, Perfil, Notificações
  - Login, Signup, Onboarding
  - Telas de detalhe (GoalDetail, TaskDetail, ContactDetail, AccountDetail)
- [ ] Adicionar eventos de ação:
  - `logTransactionAdded`, `logGoalCreated`, `logTaskCreated`, `logContactCreated`
  - `logLogin`, `logSignUp` (já existem no serviço, só chamar)

### 14. iOS Code Signing
- [ ] Criar certificado de distribuição Apple
- [ ] Criar provisioning profile para App Store
- [ ] Configurar no Xcode ou via Fastlane

### 15. Ajustes de UI/UX
- [ ] Verificar espaçamentos inconsistentes entre telas
- [ ] Substituir strings hardcoded por `AppLocales.of(context).translate()`
- [ ] Verificar estado de loading/empty/error em todas as telas que carregam dados do Firestore
- [ ] Adicionar tratamento de erro quando Firestore está offline

### 16. Política de Privacidade
- [ ] O ficheiro `assets/content/politica_privacidade.txt` já existe ✅
- [ ] Vincular no cadastro (já existe link no checkbox) ✅
- [ ] Criar versão em inglês: `assets/content/privacy_policy.txt`
- [ ] Submeter para Google Play + App Store

---

## ⏱️ Estimativa de Esforço

| Prioridade | Itens | Esforço Estimado |
|-----------|-------|------------------|
| 🔴 Crítico | 1-6 | 2-3 dias |
| 🟡 Importante | 7-10 | 3-5 dias |
| 🟢 Sugestões | 11-16 | 3-5 dias |

**Total estimado:** 8-13 dias para lançamento completo

---

## 📊 Resumo Geral

| Categoria | Score | Notas |
|-----------|-------|-------|
| **Funcionalidades Core** | 98% | Tudo implementado — finanças, metas, tarefas, contactos, notificações, admin |
| **Infraestrutura Firebase** | 95% | Auth, Firestore, Storage, Functions, Analytics, Crashlytics, Messaging |
| **UX/UI** | 90% | Tema claro/escuro, i18n PT/EN, animações, responsivo |
| **Publicação** | 20% | ⚠️ Keystore, SHA-1, Apple Sign-In, ícones, screenshots, descrições |
| **Testes** | 15% | ⚠️ Só testes unitários básicos — widget/integração/golden em falta |
| **Verificação de Email** | 0% | ❌ Não implementada — item #6 crítico |

**Geral: ~85% pronto para lançamento**
