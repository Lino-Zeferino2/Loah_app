# Manage Reflections CRUD - Implementation Plan

## Steps

### Step 1: Create Reflection Model
- [x] Create `lib/models/reflection_model.dart` with `id`, `text`, `imageUrl`, `createdAt`, `active` fields

### Step 2: Create Reflection Service
- [x] Create `lib/core/services/reflection_service.dart` with Firestore CRUD + Firebase Storage image upload

### Step 3: Rewrite ManageReflectionsScreen
- [x] Convert to `StatefulWidget`
- [x] List all reflections from Firestore in StreamBuilder
- [x] FAB to create new reflection
- [x] Bottom sheet with text field + image picker
- [x] Delete functionality with confirmation dialog

### Step 4: Update Dashboard
- [x] Update `dashboard_screen.dart` to fetch active reflection from Firestore
- [x] Pass dynamic data to `DailyReflectionCard`

### Step 5: Verify compilation
- [x] Run `flutter analyze` — No issues found!

