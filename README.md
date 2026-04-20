# HappyShopper

HappyShopper is a Flutter grocery list app for creating and sharing shopping lists with other people. Users can create an account, sign in, make grocery lists, add items with quantities and notes, assign items to members, and manage who has access to each list. Profile details and theme preferences are editable from inside the app, and data syncs through Supabase in realtime.

## What It Does

- Email and password sign-up/sign-in
- Create, view, and delete grocery lists
- Add items with quantity, notes, icon, and assignee
- Mark items complete or delete them
- Invite members to a list by email
- Leave a shared list or remove members as the owner
- Edit your display name and profile icon
- Switch between built-in color themes
- Search across your lists and items

## Requirements

- Flutter SDK 3.11 or newer
- A connected device, emulator, simulator, or browser
- Internet access for the configured Supabase backend

## How To Run

From the project root:

```bash
flutter pub get
flutter run
```

Flutter will start the app on the default connected device. To launch a specific target, use one of the platform device IDs:

```bash
flutter devices
flutter run -d chrome
```

## How To Test

```bash
flutter test
```

## Notes

Supabase is initialized in `lib/main.dart`. If you want to point the app at a different backend, update the Supabase URL and anon key there.
