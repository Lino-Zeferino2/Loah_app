# Plano de Correção - Erro ao entrar com Google (PERMISSION_DENIED no Firestore)

## ✅ Ação 1: Melhorar tratamento de erro no login/signup Google e Apple
- [x] Adicionar captura de `FirebaseException` do Firestore no `login_screen.dart` (`_handleGoogleLogin`)
- [x] Adicionar captura de `FirebaseException` do Firestore no `login_screen.dart` (`_handleAppleLogin`)
- [x] Adicionar captura de `FirebaseException` do Firestore no `signup_screen.dart` (`_handleGoogleSignUp`)
- [x] Adicionar captura de `FirebaseException` do Firestore no `signup_screen.dart` (`_handleAppleSignUp`)
- [x] Adicionar import `package:firebase_core/firebase_core.dart` em ambos os arquivos
- [x] Mensagens exibidas em português com orientação clara

## ❓ Ação 2: Instalar Firebase CLI e implantar regras do Firestore
- [ ] Pendente - Necessário instalar Firebase CLI e executar `firebase deploy --only firestore:rules`

