# Repository Guidelines

## Project Structure & Module Organization
The SwiftUI app source sits in `breath/`, with screens under `View/`, shared models and timers in the root, and Core Data helpers in `Controller/`. Asset catalogs and previews live in `breath/Assets` and `breath/Preview Content`. The Core Data model (`breath.xcdatamodeld`) backs the `PersistenceController`. Tests are split between `breathTests/` for unit coverage and `breathUITests/` for UI flows. Open `breath.xcodeproj` to inspect targets or adjust schemes.

## Build, Test, and Development Commands
- `open breath.xcodeproj` — launch the project in Xcode with the default `breath` scheme.
- `xcodebuild -project breath.xcodeproj -scheme breath -sdk iphonesimulator -destination "platform=iOS Simulator,name=iPhone 15" build` — headless build that matches CI expectations.
- `xcodebuild -project breath.xcodeproj -scheme breathTests -sdk iphonesimulator test` — run XCTest bundles (includes UI tests when the simulator destination is provided).
- For localized previews, run `xcrun simctl boot "iPhone 15"` ahead of UI test execution.

## Coding Style & Naming Conventions
Follow Swift 5 defaults with four-space indentation and lint-friendly `MARK:` sections (see `ResumableTimer.swift`). Use `UpperCamelCase` for types and view structs (`MainView`, `ExercisesView`), `lowerCamelCase` for variables and functions, and prefix view state with context (e.g., `breathingPhaseTimer`). Keep SwiftUI body builders short and extract subviews into `View/` when they exceed ~120 lines. Prefer value types (`struct`) for UI and keep side-effecting logic in helpers or controllers.

## Testing Guidelines
Use XCTest (`breathTests.swift`) for unit coverage and `XCTestCase` UI suites in `breathUITests`. Name tests with the `test_<Condition>_<Expectation>` pattern, mirroring the target (e.g., `testExerciseFlowCompletes`). Ensure new logic has deterministic unit coverage and add UI tests for navigation regressions. Run the `xcodebuild … test` command before submitting; target a minimum of 80% coverage on new features and attach simulator logs when diagnosing failures.

## Commit & Pull Request Guidelines
Commits follow short, lower-case summaries (see `git log`: “ui improvements”). Keep each commit scoped to a feature or fix and use the imperative mood when possible (“add breathing presets”). Pull requests should include: a concise summary, linked issue or ticket, simulator screenshots for UI changes, reproduction steps for bug fixes, and a checklist of tests executed. Flag Core Data schema or timer behavior changes explicitly so reviewers can re-run affected flows.

## Data & Configuration Notes
Persistence is centralized in `Controller/Persistence.swift` using `NSPersistentCloudKitContainer`. Update the `breath` data model and regenerate managed object subclasses together. For Core Data previews, seed sample entities via `PersistenceController.preview` and keep UUID generation consistent with production initializers. When adding configuration, prefer `Info.plist` entries over hard-coded strings and document secrets management before committing.
