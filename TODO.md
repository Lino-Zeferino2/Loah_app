# TODO - Help Center Enhancements

## Step 1: Add `getAllArticles()` method to HelpCenterService
- [x] Add method to fetch all articles ordered by createdAt
- [x] File: `lib/core/services/help_center_service.dart`

## Step 2: Full-Screen Modals in Manage Help Center
- [x] Convert `_openCategorySheet()` to full-screen dialog
- [x] Convert `_openArticleSheet()` to full-screen dialog
- [x] Convert `_openMessageDetail()` to full-screen dialog
- [x] File: `lib/screens/admin/manage_help_center_screen.dart`

## Step 3: Add getUserMessages() and addUserFollowUp() to HelpCenterService
- [x] Add getUserMessages() - queries messages by userId
- [x] Add addUserFollowUp() - updates message with follow-up text
- [x] File: `lib/core/services/help_center_service.dart`

## Step 4: Add userFollowUp fields to HelpMessage model
- [x] Added userFollowUp (String?) and userFollowUpAt (Timestamp?) fields
- [x] File: `lib/models/help_center_models.dart`

## Step 5: Create MyMessagesScreen
- [x] List of user's messages with status badges
- [x] Detail screen with thread view (user message, admin reply, follow-up, reply input)
- [x] File: `lib/screens/support/my_messages_screen.dart`

## Step 6: Add "As Minhas Mensagens" button to Help Center
- [x] Added import and OutlinedButton in _HelpContactSection
- [x] File: `lib/screens/support/help_center_screen.dart`

## Step 7: Verify & Test
- [x] Run `flutter analyze` - **No issues found!**
