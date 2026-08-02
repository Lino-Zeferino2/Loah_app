# TODO — Implementar "Apagar Conta" (GDPR/LGPD)

## Steps

- [x] Analisar estrutura de dados (Firestore subcollections, Storage, Auth)
- [x] Criar plano e obter aprovação do utilizador

### Backend / Serviços
- [x] `lib/core/services/user_service.dart`: adicionar `deleteUserData()` e `deleteUserContent()`
- [x] `lib/core/services/auth_service.dart`: adicionar `reauthenticate()` e `deleteAccount()`
- [x] `functions/index.js`: adicionar trigger `onUserDeleted` para limpar mensagens de suporte

### UI
- [x] `lib/screens/profile/profile_screen.dart`: botão "Excluir Conta" + confirmação + reautenticação
- [x] `lib/core/l10n/app_localizations.dart`: traduções pt/en da funcionalidade

### Validação
- [ ] Correr `flutter analyze` — sem issues

