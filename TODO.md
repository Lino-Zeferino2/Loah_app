# TODO — Detalhes Funcionais Pendentes para Lançamento

## Tarefas a Completar

### 1. Upload de foto de perfil para contatos (Firebase Storage)
- [x] AddContactScreen: upload da foto selecionada para Firebase Storage — **Implementado** (`ContactService.uploadAvatar` + upload no `_submit`; foto antiga no Storage é apagada ao substituir)
- [x] ContactDetailScreen: exibir foto do Storage corretamente — **Já usava `GoalImage(path: avatarUrl)`** (trata URLs http/https e caminhos locais), agora a URL de Storage é persistida no Firestore e renderizada corretamente

### 2. Corrigir build.gradle.kts (compilação Android)
- [x] Import java.util.Properties corrigido
- [x] Verificar se path do keystore funciona (storeFile = rootProject.file(it)) — **Corrigido**
- [x] Testar `flutter build apk --release` — **✅ APK gerado (64,6 MB) e assinado com release keystore (CN=Loah App)**

### 3. RecurringEngine — Integração completa
- [x] Já está integrado no FinancesScreen.initState()
- [x] Já gera transações automaticamente

### 4. Meta taskChecklist — Modo de progresso por tarefas
- [x] GoalProgress.of() já suporta taskChecklist
- [x] GoalProgressMode.taskChecklist existe no modelo
- [x] AddGoalScreen já usa taskChecklist quando não tem valor alvo
- [x] GoalDetailScreen: mostrar progresso de tarefas corretamente — **Anel de progresso mostra "X de Y tarefas concluídas" em vez de "CONCLUÍDO" quando o progresso é parcial**

### 5. Validação de email — Melhorias
- [x] EmailVerificationScreen existe
- [x] Auto-verificação a cada 3 segundos
- [x] Link para reenvio de email
- [x] Tratar navegação após verificação (para Onboarding ou RootShell) — Corrigido: `pushAndRemoveUntil` com `(route) => false` para limpar toda a pilha

### 6. Metas: Fundo de Emergência especial
- [x] EmergencyGoalCard widget existe
- [x] FinançasScreen já mostra emergencyGoal se existir
- [ ] Criar goal de fundo de emergência default quando usuário não tem nenhum

### 7. Nome do app — Branding
- [x] Android: mudar label de "loahapp" para "Loah"
- [x] iOS: mudar CFBundleDisplayName para "Loah"
- [x] iOS: mudar CFBundleName para "Loah"

### 8. ProGuard
- [x] proguard-rules.pro existe com regras Flutter + Firebase

### 9. Testes
- [x] Executar `flutter test` e verificar se passa — **✅ 78 testes, todos passam** (corrigido bug de teste date-dependent em `ReportSummary.balanceHistory` que usava datas do mês atual não garantidas no passado)
- [ ] Adicionar testes de widget para telas principais

### 10. Firebase App Content (Políticas)
- [ ] Upload de política_privacidade.txt para Firestore (appContent)
- [ ] Upload de termos_condicoes.txt para Firestore
- [ ] Upload de sobre_nos.txt para Firestore

---

## ✅ Realizado nesta sessão

### Keystore de produção Android
- [x] **`android/app/build.gradle.kts`**: `storeFile` corrigido para usar `rootProject.file(it)` em vez de `file(it)`, resolvendo o caminho a partir da raiz do projeto
- [x] **`proguard-rules.pro`**: Adicionadas regras `-dontwarn` para `com.google.android.play.core.*` — resolve o erro R8 `Missing class` (deferred components do Flutter não são usadas). Nota: a via alternativa `com.google.android.play:core:1.10.3` foi tentada mas causou conflito de classes duplicadas com `core-common:2.0.3` e foi removida.
- [x] **Key verified**: `keytool -list -v -keystore android/release-keystore.jks` confirma alias=`loah`, validade OK
- [x] **`flutter build apk --release`**: **✅ SUCESSO** — APK gerado em `build/app/outputs/flutter-apk/app-release.apk` (64,6 MB) e **assinado** com o release keystore (certificado: `CN=Loah App, OU=Development, O=Loah, C=PT`, SHA-256 `5f80b55b...`)

### Deep linking para recovery de senha (Firebase Email Link)
- [x] **`pubspec.yaml`**: Adicionada dependência `app_links: ^6.3.3`
- [x] **`lib/core/services/deep_link_service.dart`**: Novo serviço que captura links iniciais (cold start) e stream (warm start), analisa o URI e extrai `oobCode` para reset de senha
- [x] **`lib/screens/auth/reset_password_screen.dart`**: Nova tela estilizada (consistente com o design do app) que valida o `oobCode` via `verifyPasswordResetCode()` e permite definir nova senha
- [x] **`lib/core/services/auth_service.dart`**: Adicionados métodos:
  - `sendPasswordResetEmailWithLink()` — envia email com `ActionCodeSettings` (usa `linkDomain` no lugar do obsoleto `dynamicLinkDomain`)
  - `verifyPasswordResetCode()` — valida o código de ação
  - `resetPassword()` — confirma a redefinição via `confirmPasswordReset()`
- [x] **`lib/screens/auth/password_recovery_screen.dart`**: Atualizado para usar `sendPasswordResetEmailWithLink()` com `handleCodeInApp: true` em mobile
- [x] **`lib/main.dart`**: Registado `onPasswordReset` callback + `navigatorKey` global + inicialização do `DeepLinkService`
- [x] **`AndroidManifest.xml`**: Adicionados dois `intent-filter` para deep links (https Firebase + custom scheme `loahapp://`)
- [x] **`ios/Runner/Runner.entitlements`**: Novo ficheiro com `com.apple.developer.associated-domains: applinks:loahapp.firebaseapp.com`
- [x] **`ios/Runner/Info.plist`**: Adicionado `CFBundleURLTypes` para o scheme `loahapp`
- [x] **`ios/Runner.xcodeproj/project.pbxproj`**: Runner.entitlements ligado ao grupo Runner + `CODE_SIGN_ENTITLEMENTS` nas configs Debug/Release/Profile
- [x] **`flutter analyze`**: **0 issues found** ✅
- [x] **`flutter build apk --release`**: **✅ SUCESSO** — APK de produção assinado gerado (ver secção Keystore acima)

