# Gemini Flutter Extension Rules

These rules are derived from the [Gemini Flutter Extension](https://github.com/gemini-cli-extensions/flutter) and are authoritative for this project.

## 🛠️ Mandatory Tool Usage
- **Prefer MCP Tools**: Always use the `dart` MCP server tools instead of their command line equivalents.
  - Use `analyze_files` instead of `flutter analyze`.
  - Use `dart_fix` and `dart_format` instead of CLI formatting/fixing.
  - Use `pub` tool for all dependency management (`add`, `remove`, `get`).
  - Use `launch_app` and `run_tests` for application lifecycle.
  - Use `list_devices` to discover targets.

## 📦 Dependency Management
- **No Manual Pubspec Edits**: Never manually modify dependencies in `pubspec.yaml`. Always use the `pub` MCP tool.
- **Dev Dependencies**: Use the `dev:` prefix when adding dev dependencies (e.g., `pub add dev:package_name`).
- **Overrides**: Use the `override:` prefix for dependency overrides.

## ✨ Coding Standards
- **SOLID & Declarative**: Apply SOLID principles. Write concise, declarative Dart code.
- **Composition**: Favor composition over inheritance for widgets and logic.
- **Immutability**: Prefer immutable data structures and widgets.
- **Design Patterns**: Separate ephemeral state from app state. Use a robust state management solution (already aligned with project's Riverpod usage).
- **Style**:
  - Max line length: 80 characters.
  - PascalCase for classes, camelCase for members/variables, snake_case for files.
  - Short functions (< 20 lines) with a single purpose.

## ✅ Quality Assurance
- Run `analyze_files` after every significant code change.
- Run `dart_fix` and `dart_format` before proposing any changes.
- Ensure tests pass via `run_tests` before finalizing tasks.
