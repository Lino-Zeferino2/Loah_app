# TODO — Detalhes Funcionais Pendentes para Lançamento

## Tarefas a Completar

### 1. Upload de foto de perfil para contatos (Firebase Storage)
- [ ] AddContactScreen: upload da foto selecionada para Firebase Storage
- [ ] ContactDetailScreen: exibir foto do Storage corretamente

### 2. Corrigir build.gradle.kts (compilação Android)
- [x] Import java.util.Properties corrigido
- [ ] Verificar se path do keystore funciona (storeFile = file(it))
- [ ] Testar `flutter build apk --release`

### 3. RecurringEngine — Integração completa
- [x] Já está integrado no FinancesScreen.initState()
- [x] Já gera transações automaticamente

### 4. Meta taskChecklist — Modo de progresso por tarefas
- [x] GoalProgress.of() já suporta taskChecklist
- [x] GoalProgressMode.taskChecklist existe no modelo
- [x] AddGoalScreen já usa taskChecklist quando não tem valor alvo
- [ ] GoalDetailScreen: mostrar progresso de tarefas corretamente

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
- [ ] Android: mudar label de "loahapp" para "Loah"
- [ ] iOS: mudar CFBundleDisplayName para "Loah"

### 8. ProGuard
- [x] proguard-rules.pro existe com regras Flutter + Firebase

### 9. Testes
- [ ] Executar `flutter test` e verificar se passa
- [ ] Adicionar testes de widget para telas principais

### 10. Firebase App Content (Políticas)
- [ ] Upload de política_privacidade.txt para Firestore (appContent)
- [ ] Upload de termos_condicoes.txt para Firestore
- [ ] Upload de sobre_nos.txt para Firestore

