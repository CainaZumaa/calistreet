## Quick orientation for code-writing agents

This repository is a Flutter app (Dart) named Calistreet. Below are the minimal, actionable facts an AI coding agent needs to be productive here.

- Language / framework: Flutter (Dart) — entry point `lib/main.dart`.
- State & API: Supabase is the backend. Key integration points:

  - `lib/config/supabase_config.dart` — loads `.env` and provides URL/keys with fallbacks.
  - `lib/services/auth_service.dart` — Supabase initialization, service-role client creation, signUp/signIn, profile fetching (`user_profiles`) and a static in-memory `currentUser` holder.
  - Database tables referenced in code: `users` and `user_profiles` (examples: insert/select in `AuthService`).

- Environment: `.env` file is required (listed in `pubspec.yaml` assets). Look for these environment variables: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `USE_SERVICE_ROLE`.

- App lifecycle and assumptions:

  - `lib/main.dart` loads dotenv and calls `AuthService.initialize()` before `runApp`.
  - `AuthWrapper` in `main.dart` checks `AuthService.currentUser` to decide whether to show `HomeScreen` or `LoginScreen`.
  - `AuthService.signIn` / `signUp` return maps with status and user info but do not automatically set `currentUser`; callers are expected to call `AuthService.setCurrentUser(...)` after a successful login/signup.

- UX & navigation patterns:

  - Screens live under `lib/screens/*` (examples: `home_screen.dart`, onboarding screens). Use `Navigator.push(...)` / `pushReplacementNamed` as shown in `home_screen.dart`.
  - UI uses a dark Material theme (see `CalistreetApp` in `main.dart`) and custom colors (`0xFF007AFF`, `0xFF1A1A1A` etc.). Mimic these colors when adding components.

- Conventions & structure to follow when editing or adding features:

  - Keep service/API logic in `lib/services/` (e.g., `auth_service.dart`).
  - Put configuration or secrets-handling helpers in `lib/config/` (use `supabase_config.dart` pattern for `.env` fallback logic).
  - UI code belongs in `lib/screens/` and small reusable widgets can live alongside or in a `lib/widgets/` folder if needed.
  - Models live in `lib/models/` (e.g., `user_onboarding_data.dart`).

- Notable code patterns / gotchas to preserve:

  - Password hashing is currently performed client-side via SHA256 in `AuthService._hashPassword`. Sign-in and sign-up use the hashed value when reading/inserting into `users` table.
  - `AuthService.createServiceRoleClient()` uses the service role key and is used for direct DB queries (insert/select). New server-side mutations that require elevated privileges should use this helper.
  - `supabase_flutter` is used for app-level client (`Supabase.initialize`) and `supabase` core is used for the service-role client.

- Build / run / debug (developer workflows)

  - Install deps: `flutter pub get` (repo uses `pubspec.yaml` with `flutter_dotenv`, `supabase_flutter` etc.).
  - Run locally (example): `flutter run` or `flutter run -d linux` / `-d emulator-5554`.
    - **Local Supabase dev**:
    - Install Supabase CLI: `brew install supabase/tap/supabase` (or npm/scoop)
    - Start services: `supabase start` (creates local DB at `http://localhost:54321`)
    - Update `.env` with local URL and keys (see `supabase status` output)
    - Create tables via migrations in `supabase/migrations/`
    - Access Supabase Studio at `http://localhost:54323`
    - Stop services: `supabase stop`
  - Build: `flutter build apk` or `flutter build ios` (platform-specific configuration exists under `android/` and `ios/`).
  - Tests: `flutter test` (there is a `test/widget_test.dart`).
  - If dotenv fails to load during `main()`, the app shows a minimal error screen (see `main.dart`) — ensure `.env` is present for normal dev runs.

- Examples of code fixes/features an agent can implement quickly

  - Add `AuthService.setCurrentUser({...})` call after successful sign-in in the login flow (look at `main.dart` login UI and `AuthService.signIn`).
  - Add defensive null checks when reading `AuthService.currentUser['user_id']` (see `home_screen.dart` `_loadUserData`).
  - When adding new DB access, reuse `AuthService.createServiceRoleClient()` for server-permissioned queries.

- Files to read for context when working on logic or the UI:
  - `lib/config/supabase_config.dart` (env loading + fallbacks)
  - `lib/services/auth_service.dart` (authentication and DB helpers)
  - `lib/main.dart` (app init, AuthWrapper, login UI)
  - `lib/screens/home_screen.dart`, `lib/screens/profile_screen.dart`, `lib/screens/onboarding/*` (UI patterns and navigation)
  - `pubspec.yaml` (packages in use and `.env` asset)

If anything in this summary is incomplete or you want more details (e.g., a short mapping of DB columns for `users` / `user_profiles`, or where login currently calls `signIn`), tell me which area to expand and I'll update this file.
