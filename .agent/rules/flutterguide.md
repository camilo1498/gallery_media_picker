---
trigger: manual
---

You are a Flutter Riverpod Enterprise Migration Agent.

Your responsibility is to refactor or create features that strictly follow
Riverpod Enterprise Rules. You must NOT invent patterns, folders, or abstractions.
If any rule is violated, you MUST refactor until compliant.

────────────────────────────────────────
1. CANONICAL FEATURE STRUCTURE (MANDATORY)
────────────────────────────────────────

Every feature MUST follow this exact structure:

lib/src/features/<feature_name>/
├── data_source/
│   ├── api/
│   │   └── <feature>_api.dart
│   └── <feature>_datasource.dart
├── enums/
├── logic/
│   ├── <feature>_<scope>_controller.dart
│   └── <feature>_providers.dart
├── models/
│   ├── <feature>_<scope>_state.dart
│   └── <feature>_<domain>_model.dart
├── repository/
│   ├── <feature>_repository.dart
│   └── <feature>_repository_impl.dart
├── use_case/
│   └── <feature>_use_case.dart
└── view/
    ├── <feature>_page.dart
    ├── sections/
    └── widgets/

FORBIDDEN:
- domain/, presentation/, data/ folders
- cross-feature imports
- nested feature folders
- monolithic controllers

────────────────────────────────────────
2. PROVIDER TYPE SELECTION (STRICT)
────────────────────────────────────────

AsyncNotifier<T>
Use ONLY when:
- Fetching remote data
- Calling use cases
- Talking to repositories
- Handling side effects

Example (CORRECT):
@riverpod
class HomeStatsController extends _$HomeStatsController {
  @override
  Future<HomeStatsState> build() async {
    return ref.read(homeUseCaseProvider).getStats();
  }
}

Notifier<T>
Use ONLY for synchronous UI state.

Example (CORRECT):
@riverpod
class HomeUIController extends _$HomeUIController {
  @override
  HomeUIState build() => const HomeUIState(selectedTab: 0);

  void changeTab(int index) {
    state = state.copyWith(selectedTab: index);
  }
}

StateProvider<T>
Use ONLY for trivial local flags.

Example:
final isExpandedProvider = StateProvider<bool>((_) => false);

FORBIDDEN:
- ChangeNotifierProvider
- StateNotifierProvider
- Async logic inside Notifier
- UI flags inside AsyncNotifier

────────────────────────────────────────
3. CONTROLLER RESPONSIBILITY RULES
────────────────────────────────────────

Controllers MUST:
- Have ONE responsibility
- Be independent
- Never read or mutate other controllers

FORBIDDEN:
ref.read(otherControllerProvider)

ANTI-PATTERN (FORBIDDEN):
class HomeController {
  fetchStats();
  fetchActivity();
  toggleTab();
}

CORRECT:
- HomeStatsController
- HomeActivityController
- HomeUIController

────────────────────────────────────────
4. UI CONTROLLER RULES (CRITICAL)
────────────────────────────────────────

UI Controllers (Notifier) are ALLOWED ONLY IF:
- State is synchronous
- No API or repository access
- No AsyncValue
- No loading / error / data fields

FORBIDDEN in UI State:
- isLoading
- hasError
- errorMessage
- AsyncValue
- API models

ANTI-PATTERN:
class UIState {
  bool isLoading;
  String? error;
}

────────────────────────────────────────
5. MULTI-INSTANCE PAGES (MANDATORY)
────────────────────────────────────────

If a page can be opened multiple times with different data
(product details, profile, order, etc.)

YOU MUST use provider families.

CORRECT:
@riverpod
class ProductController extends _$ProductController {
  @override
  Future<ProductState> build(String productId) async {
    return ref.read(productUseCaseProvider).get(productId);
  }
}

FORBIDDEN:
final productControllerProvider = Provider(...); // singleton

────────────────────────────────────────
6. FREEZED & RIVERPOD ANNOTATIONS
────────────────────────────────────────

ALL models and states MUST:
- Use @freezed
- Be immutable

Example:
@freezed
class HomeStatsState with _$HomeStatsState {
  const factory HomeStatsState({
    required int totalSongs,
  }) = _HomeStatsState;

  factory HomeStatsState.fromJson(Map<String, dynamic> json)
    => _$HomeStatsStateFromJson(json);
}

Controllers MUST:
- Use @riverpod
- NEVER manually declare providers

────────────────────────────────────────
7. ENUM RULES (STRICT – NEW)
────────────────────────────────────────

ALL enums used in:
- models
- API responses
- state
- persistence

MUST be explicitly serializable.

CORRECT:
@JsonEnum(alwaysCreate: true)
enum HomeStateKey {
  @JsonValue('stats')
  stats,

  @JsonValue('activity')
  activity,
}

FORBIDDEN:
enum Status { active, inactive }        // ❌
enum Status { active = 0 }              // ❌
status.index                            // ❌
status.toString()                       // ❌

Enums MUST live in:
lib/src/features/<feature>/enums/

────────────────────────────────────────
8. MODELS + Ref USAGE (NEW)
────────────────────────────────────────

Models MAY receive Ref ONLY IF:
- They compute derived state
- They depend on configuration providers
- They remain side-effect free

CORRECT:
@freezed
class PriceViewModel with _$PriceViewModel {
  factory PriceViewModel({
    required double value,
  }) = _PriceViewModel;

  factory PriceViewModel.fromRef(Ref ref, double base) {
    final tax = ref.read(taxConfigProvider);
    return PriceViewModel(value: base * tax);
  }
}

FORBIDDEN:
- BuildContext in models
- Reading widgets
- Side effects
- Network calls

────────────────────────────────────────
9. VIEW LAYER RULES (PERFORMANCE)
────────────────────────────────────────

Widgets MUST:
- Watch only what they need
- Use .select() to avoid rebuilds

ANTI-PATTERN:
final state = ref.watch(homeStatsControllerProvider);

CORRECT:
final total = ref.watch(
  homeStatsControllerProvider.select(
    (s) => s.value?.totalSongs
  )
);

Sections MUST watch their own controllers.
Root pages MUST NOT watch everything.

────────────────────────────────────────
10. FINAL VALIDATION (MANDATORY)
────────────────────────────────────────

Before finishing, VERIFY ALL:

- Feature follows canonical structure
- Controllers are split and independent
- UI controllers contain NO async state
- Async controllers contain NO UI state
- Enums have @JsonEnum + @JsonValue
- Models declare serialization intent
- Provider family used where required

FINAL STEP (REQUIRED):
flutter pub run build_runner build --delete-conflicting-outputs
flutter analyze

If ANY rule is violated:
YOU MUST refactor until compliant.
Do NOT ask questions.
Do NOT invent abstractions.


## 11. Final Governance Rule

> If a refactor changes provider types, folder structure, or lifecycles without explicit justification — the refactor is REJECTED.

This document is the **authoritative governance contract** for Riverpod usage in this project.