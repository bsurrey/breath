# Repository Guidelines

## Project Structure & Module Organization
SwiftUI source lives under `breath/`, with feature views in `breath/View/` and shared models, timers, and helpers in the module root. Persistence utilities sit in `breath/Controller/`, and the Core Data schema is defined in `breath.xcdatamodeld`. Static assets and preview fixtures are under `breath/Assets` and `breath/Preview Content`. XCTest bundles live in `breathTests/` for unit coverage and `breathUITests/` for UI scenarios. Open `breath.xcodeproj` to inspect schemes or tweak targets.

## Build, Test, and Development Commands
- `open breath.xcodeproj` — launches the project in Xcode with the default `breath` scheme for interactive dev.
- `xcodebuild -project breath.xcodeproj -scheme breath -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 15" build` — CI-equivalent simulator build.
- `xcodebuild -project breath.xcodeproj -scheme breathTests -sdk iphonesimulator test` — runs unit and UI tests; boot the target simulator with `xcrun simctl boot "iPhone 15"` beforehand.

## Coding Style & Naming Conventions
Follow Swift 5 defaults with four-space indentation. Use `UpperCamelCase` for types and extracted views (`MainView`, `ExercisesView`) and `lowerCamelCase` for properties, functions, and state (e.g., `breathingPhaseTimer`). Keep SwiftUI bodies brief by extracting subviews once they exceed ~120 lines. Organize large files with `// MARK:` sections mirroring `ResumableTimer.swift`. Prefer value types for UI and isolate side effects in controllers or helpers.

## Testing Guidelines
Author deterministic XCTest cases in `breathTests/` and UI flows in `breathUITests/`. Name tests using `test_<Condition>_<Expectation>` (e.g., `testExerciseFlowCompletes`). Target ≥80% coverage on new work and run the simulator-backed `xcodebuild … test` command before submitting. Attach relevant simulator logs when diagnosing failures.

## Commit & Pull Request Guidelines
Commit summaries are short, lowercase, and imperative (e.g., `add breathing presets`). Keep each commit focused on a single fix or feature. Pull requests should include a concise summary, linked issue or ticket, and screenshots for UI updates. Document reproduction steps for bug fixes, list tests executed, and call out Core Data schema or timer-behavior changes so reviewers can re-run affected flows.

## Data & Configuration Notes
`PersistenceController` centralizes CloudKit-backed storage. Update `breath` data model files and regenerate managed object subclasses together to avoid runtime mismatches. Seed previews with `PersistenceController.preview`, mirroring production UUID patterns. Prefer `Info.plist` keys or configuration files over hard-coded secrets, and document any credential handling before merging.
