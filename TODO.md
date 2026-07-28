# Notification System Fixes

## Progress

- [x] Analyze code and identify issues
- [x] Plan fixes
- [x] **Fix 1: Navigate to correct screens on notification tap**
  - [x] Tasks → TaskDetailScreen
  - [x] Goals → GoalDetailScreen
  - [x] Contacts → ContactDetailScreen
  - [x] Finance (non-recurring) → BudgetsScreen
  - [x] System → mark as read only
  - [x] All taps mark notification as read
- [x] **Fix 2: Add filter to notifications screen**
  - [x] Filter by category (Todas, Contactos, Tarefas, Metas, Finanças, Sistema)
  - [x] Filter by read/unread status ("Não lidas" chip with count)
- [x] **Fix 3: Visual read/unread state in NotificationCard**
  - [x] Blue dot indicator on unread notifications
  - [x] Dimmed colors for read notifications
  - [x] Border accent changes for read/unread
- [ ] **Fix 4: Push notifications not arriving on device**
  - Deploy Cloud Functions to Firebase:
    ```bash
    cd functions && npm install && firebase deploy --only functions
    ```
  - Check Firebase Console > Functions for error logs
  - Verify FCM tokens are being saved in Firestore at `/users/{userId}/fcmTokens/`
  - Ensure the Cloud Function `sendNotificationOnWrite` is properly deployed and triggered
  - For real device testing, build a release APK/IPA with proper Firebase config

