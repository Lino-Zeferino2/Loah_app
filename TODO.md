# Plano: Substituir Notificações Estáticas por Notificações Reais com Firebase

## ✅ Passos Concluídos
- [x] Análise do projeto (estrutura, dependências, Firebase configurado)
- [x] 1.1 Adicionar `isRead` e `toFirestore()/fromFirestore()` ao model
- [x] 2.1 Criar `lib/core/services/notification_repository.dart`
- [x] 3.1 Criar `lib/core/services/notification_service.dart` (FCM init, token, foreground/background)
- [x] 4.1 Criar `lib/core/services/notification_scheduler.dart` (verifica contactos, tarefas, etc. e escreve no Firestore)
- [x] 5.1 Inicializar NotificationService no startup
- [x] 6.1 Substituir NotificationGenerator por Firestore stream
- [x] 7.1 Android: permissão `POST_NOTIFICATIONS`
- [x] 8.1 Criar `functions/package.json`
- [x] 8.2 Criar `functions/index.js` com todas as Cloud Functions
- [x] 8.3 Criar `functions/.gitignore`
- [x] Adicionar dependência `flutter_local_notifications`

## 📋 Próximos Passos
- [ ] 9. Executar `flutter pub get`
- [ ] 10. Executar `npm install` na pasta `functions/`
- [ ] 11. Fazer deploy das Cloud Functions com `firebase deploy --only functions`
- [ ] 12. Testar a aplicação

