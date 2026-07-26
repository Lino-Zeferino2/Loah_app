# TODO - Correções de Bugs ✅

## Issues corrigidas:

### [x] 1. Bloqueio de login para utilizadores bloqueados ✅
- [x] Adicionar verificação do campo `blocked` no Firestore no login (`login_screen.dart`)
- [x] Adicionar verificação no fluxo do SplashScreen (auto-login) (`splash_screen.dart`)
- [x] Adicionar verificação nos logins sociais Google e Apple (`login_screen.dart`)

### [x] 2. Cor de estado (vermelho bloqueado / verde ativo) ✅
- [x] Card de utilizador bloqueado tem fundo vermelho claro e borda vermelha
- [x] Card de utilizador ativo tem borda verde e avatar verde
- [x] Chip de estado dinâmico: "Ativo" (verde) ou "Bloqueado" (vermelho)
- [x] Indicador visual (bolinha) ao lado do texto de estado

### [x] 3. Logout não trava mais a app ✅
- [x] Removido o listener `authStateChanges` do `ManageUsersScreen` que causava conflito de navegação
- [x] **CORREÇÃO PRINCIPAL**: Invertida a ordem do logout — primeiro navega para o LoginScreen (remove RootShell e todos os StreamListeners), DEPOIS faz signOut().
- [x] Adicionado `dispose()` no DashboardScreen para cancelar o StreamSubscription do NotificationRepository
- [x] Adicionado `import 'dart:async'` + `StreamSubscription` no DashboardScreen

