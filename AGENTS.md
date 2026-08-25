# Project agent memory

This file is the project's committed home for project-intrinsic agent knowledge: build, test, release, architecture, and sharp-edge notes that should travel with the code.

- Add durable project-specific notes here as they are discovered through real work.

## Build & verify (NO local build)

Termux/Android dev box cannot run `flutter build/run/analyze` — there is no Flutter
SDK locally (only `dart`). CI is the ONLY verifier. Push early, let
`.github/workflows/ci.yml` run `flutter analyze` + `flutter test` + build debug APK.
Put as much logic as possible in unit tests (`test/unit/`) that run on the Linux runner.

- DB tests use `sqflite_common_ffi` (in-memory) via `test/helpers/test_db.dart`.
- Flutter pinned in `pubspec.yaml` (`environment.flutter`) + `flutter-version-file`.
- APK distribution via GitHub Releases on `v*` tag. Signing slot is commented in
  both `ci.yml` and `android/app/build.gradle.kts` (falls back to debug signing).

## Architecture

Feature-first (`lib/features/<fitur>/{data,domain,presentation}`) + shared `lib/core/`.
State: Riverpod. Nav: GoRouter (`lib/core/router.dart`). Design contract lives at
`docs/ui-ux-spec.md`; technical plan (DB DDL, CI) at `docs/arsitektur-teknis.md`;
market research reference at `docs/riset-pasar.md`.

Key invariants:
- Money is `int` rupiah (no cents). Stock stored only in base unit (PCS) in
  `products.stock_base`. Every stock change writes a `stock_movements` row inside the
  SAME sqflite transaction; `SUM(stock_movements.qty_base) == products.stock_base`.
- All colors/sizes come from `AppTheme` + `AppColors`/`AppShapes` ThemeExtensions
  (`lib/core/theme/`). No hardcoded colors in widgets.
- DB schema is versioned in `lib/core/db/schema.dart`; never edit released DDL — add a
  migration in `lib/core/db/migrations.dart`.

## Maintaining this file

Keep this file for knowledge useful to almost every future agent session in this project.
Do not repeat what the codebase already shows; point to the authoritative file or command instead.
Prefer rewriting or pruning existing entries over appending new ones.
When updating this file, preserve this bar for all agents and keep entries concise.
