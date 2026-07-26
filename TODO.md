# TODO - Help Center Enhancements

## Step 1: Add `getAllArticles()` method to HelpCenterService
- [x] Add method to fetch all articles ordered by createdAt
- [x] File: `lib/core/services/help_center_service.dart`

## Step 2: Full-Screen Modals in Manage Help Center
- [x] Convert `_openCategorySheet()` to full-screen dialog
- [x] Convert `_openArticleSheet()` to full-screen dialog
- [x] Convert `_openMessageDetail()` to full-screen dialog
- [x] File: `lib/screens/admin/manage_help_center_screen.dart`

## Step 3: Enhance User Help Center Screen
- [ ] Load all articles on init alongside categories
- [ ] Add category filter chips
- [ ] Show articles filtered by selected category
- [ ] Keep popular articles section
- [ ] Keep contact section
- [ ] File: `lib/screens/support/help_center_screen.dart`

## Step 4: Verify & Test
- [ ] Run `flutter analyze` to check for errors

