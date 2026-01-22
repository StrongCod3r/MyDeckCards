# Architecture Documentation

## Overview

MyDeckCards follows the **MVVM (Model-View-ViewModel)** architectural pattern combined with **Provider** for state management. This document explains the architecture in detail.

## Architecture Pattern: MVVM

### Why MVVM?

1. **Separation of Concerns**: Each layer has a single, well-defined responsibility
2. **Testability**: Business logic is isolated from UI, making unit testing straightforward
3. **Maintainability**: Changes in one layer have minimal impact on others
4. **Reusability**: ViewModels can be shared across different views

### Layer Breakdown

```
┌─────────────────────────────────────┐
│           View Layer                │
│  (Flutter Widgets - UI Only)        │
│  - Renders UI based on ViewModel    │
│  - Handles user input                │
│  - No business logic                 │
└──────────────┬──────────────────────┘
               │
               │ Observes & Notifies
               ▼
┌─────────────────────────────────────┐
│        ViewModel Layer              │
│  (Business Logic & State)           │
│  - Processes user actions            │
│  - Manages UI state                  │
│  - Validates input                   │
│  - Communicates with Providers       │
└──────────────┬──────────────────────┘
               │
               │ Uses
               ▼
┌─────────────────────────────────────┐
│       Provider Layer                │
│  (Data Management & Coordination)   │
│  - Manages data operations           │
│  - Coordinates between Services      │
│  - Provides data to ViewModels       │
└──────────────┬──────────────────────┘
               │
               │ Uses
               ▼
┌─────────────────────────────────────┐
│        Service Layer                │
│  (Data Access & External APIs)      │
│  - Database operations               │
│  - File system access                │
│  - Asset loading                     │
└──────────────┬──────────────────────┘
               │
               │ Operates on
               ▼
┌─────────────────────────────────────┐
│         Model Layer                 │
│  (Data Entities)                    │
│  - Pure Dart classes                 │
│  - Data structures                   │
│  - Serialization logic               │
└─────────────────────────────────────┘
```

## Layer Responsibilities

### 1. Model Layer

**Location**: `lib/models/`

**Files**:
- `flashcard.dart` - Individual flashcard entity
- `deck.dart` - Deck entity with cards collection

**Responsibilities**:
- Define data structures
- Provide serialization/deserialization (toJson/fromJson)
- Implement copyWith for immutability
- No business logic or UI dependencies

**Example**:
```dart
class Deck {
  final String id;
  final String name;
  final String? icon;
  final bool archived;
  final List<Flashcard> cards;

  Deck({
    required this.id,
    required this.name,
    this.icon,
    this.archived = false,
    List<Flashcard>? cards,
  }) : cards = cards ?? [];

  // Serialization, copyWith, etc.
}
```

### 2. Service Layer

**Location**: `lib/services/`

**Files**:
- `database_service.dart` - SQLite operations
- `predefined_decks_service.dart` - Asset loading and predefined deck management

**Responsibilities**:
- Perform I/O operations (database, file system, assets)
- No business logic or UI state
- Provide low-level data access methods
- Handle platform-specific implementations

**Example**:
```dart
class DatabaseService {
  Future<void> insertDeck(Deck deck) async {
    final db = await database;
    await db.insert('decks', deckToMap(deck));
  }
  
  Future<List<Deck>> getDecks() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('decks');
    return List.generate(maps.length, (i) => deckFromMap(maps[i]));
  }
}
```

### 3. Provider Layer

**Location**: `lib/providers/`

**Files**:
- `deck_provider.dart` - Manages deck and card operations
- `settings_provider.dart` - Manages app settings and preferences

**Responsibilities**:
- Coordinate between Services and ViewModels
- Manage app-wide state using ChangeNotifier
- Provide data to multiple views/viewmodels
- Handle complex operations involving multiple services
- Notify listeners of state changes

**Example**:
```dart
class DeckProvider extends ChangeNotifier {
  final DatabaseService _databaseService;
  List<Deck> _decks = [];

  List<Deck> get decks => _decks;
  List<Deck> get activeDecks => _decks.where((d) => !d.archived).toList();
  List<Deck> get archivedDecks => _decks.where((d) => d.archived).toList();

  Future<void> createDeck(String name, String? icon) async {
    final deck = Deck(id: Uuid().v4(), name: name, icon: icon);
    await _databaseService.insertDeck(deck);
    await loadDecks();
    notifyListeners();
  }

  Future<void> archiveDeck(String deckId) async {
    final deck = _decks.firstWhere((d) => d.id == deckId);
    final archivedDeck = deck.copyWith(archived: true);
    await _databaseService.updateDeck(archivedDeck);
    await loadDecks();
    notifyListeners();
  }
}
```

### 4. ViewModel Layer

**Location**: `lib/viewmodels/`

**Files**:
- `base_viewmodel.dart` - Base class with common functionality
- `home_viewmodel.dart` - Home screen logic
- `deck_detail_viewmodel.dart` - Deck detail screen logic
- `review_viewmodel.dart` - Review session logic

**Responsibilities**:
- Handle view-specific business logic
- Validate user input
- Transform data for display
- Manage view-specific state
- Coordinate with Providers
- Expose methods for user actions

**Example**:
```dart
class HomeViewModel extends BaseViewModel {
  final DeckProvider _deckProvider;
  SortOrder _sortOrder = SortOrder.nameAsc;

  List<Deck> get decks => _getSortedDecks(_deckProvider.activeDecks);
  List<Deck> get archivedDecks => _getSortedDecks(_deckProvider.archivedDecks);

  Future<void> createDeck(String name, String? icon) async {
    if (name.trim().isEmpty) {
      throw ValidationException('Deck name cannot be empty');
    }
    
    await executeAsync(() async {
      await _deckProvider.createDeck(name.trim(), icon);
    });
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  List<Deck> _getSortedDecks(List<Deck> decks) {
    // Sorting logic based on _sortOrder
  }
}
```

### 5. View Layer

**Location**: `lib/views/`

**Structure**:
```
views/
├── home/
│   ├── home_view.dart
│   ├── archived_decks_view.dart
│   ├── about_view.dart
│   └── widgets/
├── deck_detail/
│   ├── deck_detail_view.dart
│   └── widgets/
├── review/
│   ├── review_view.dart
│   └── widgets/
└── settings/
    ├── settings_view.dart
    └── widgets/
```

**Responsibilities**:
- Render UI based on ViewModel state
- Handle user interactions (taps, swipes, gestures)
- Pass user actions to ViewModel
- Display loading/error states
- Navigation between screens
- NO business logic

**Example**:
```dart
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(
        Provider.of<DeckProvider>(context, listen: false),
      ),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return CircularProgressIndicator();
          }
          
          if (viewModel.error != null) {
            return ErrorWidget(viewModel.error!);
          }
          
          return ListView.builder(
            itemCount: viewModel.decks.length,
            itemBuilder: (context, index) {
              final deck = viewModel.decks[index];
              return DeckListItem(
                deck: deck,
                onTap: () => Navigator.push(...),
                onArchive: () => viewModel.archiveDeck(deck.id),
              );
            },
          );
        },
      ),
    );
  }
}
```

## State Management with Provider

### Provider Hierarchy

The app uses Provider at multiple levels:

```dart
void main() {
  runApp(
    MultiProvider(
      providers: [
        // Global Providers - Available throughout the app
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => DeckProvider(DatabaseService())),
      ],
      child: MyApp(),
    ),
  );
}
```

### ViewModel Scoping

ViewModels are scoped to their respective views:

```dart
class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeViewModel(
        Provider.of<DeckProvider>(context, listen: false),
      ),
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          // UI that reacts to viewModel changes
        },
      ),
    );
  }
}
```

## Data Flow

### 1. User Action Flow

```
User taps button
    ↓
View captures event
    ↓
View calls ViewModel method
    ↓
ViewModel validates input
    ↓
ViewModel calls Provider method
    ↓
Provider calls Service method
    ↓
Service performs database operation
    ↓
Service returns result
    ↓
Provider updates state
    ↓
Provider calls notifyListeners()
    ↓
ViewModel receives update (if listening)
    ↓
View rebuilds with new data
```

### 2. Data Loading Flow

```
App starts
    ↓
Provider initializes
    ↓
Provider calls Service.loadData()
    ↓
Service queries database
    ↓
Service returns List<Model>
    ↓
Provider stores data
    ↓
Provider calls notifyListeners()
    ↓
Views listening to Provider rebuild
```

## Best Practices

### 1. View Guidelines

- **Never** put business logic in views
- **Never** directly access services from views
- **Always** use Consumer or Provider.of to access state
- Keep build methods small and focused
- Extract complex widgets into separate files
- Use const constructors when possible

### 2. ViewModel Guidelines

- Extend BaseViewModel for common functionality
- Use `executeAsync()` for async operations (handles loading/error states)
- Validate all user input
- Don't hold references to BuildContext
- Call `notifyListeners()` after state changes
- Keep ViewModels testable (minimal dependencies)

### 3. Provider Guidelines

- Use ChangeNotifier for observable state
- Call `notifyListeners()` after data changes
- Keep providers focused (single responsibility)
- Don't perform UI operations in providers
- Make methods async when dealing with services

### 4. Service Guidelines

- Keep services stateless
- Focus on one type of operation (database, files, etc.)
- Return data, don't manage state
- Handle errors appropriately
- Make methods pure functions when possible

### 5. Model Guidelines

- Keep models immutable (use final fields)
- Provide copyWith for creating modified copies
- Implement toJson/fromJson for serialization
- No business logic in models
- Use value objects for complex types

## Testing Strategy

### Unit Tests

- **Models**: Test serialization/deserialization
- **ViewModels**: Test business logic, validation, state changes
- **Services**: Test data access methods (with mocked database)
- **Providers**: Test data coordination and state management

### Widget Tests

- Test view rendering with different states
- Test user interactions
- Mock ViewModels and Providers

### Integration Tests

- Test complete user flows
- Test navigation between screens
- Test data persistence

## Future Improvements

1. **Dependency Injection**: Implement proper DI container (GetIt)
2. **Repository Pattern**: Add repository layer between Providers and Services
3. **Use Cases**: Introduce use case layer for complex business operations
4. **Immutable State**: Consider using freezed for immutable models
5. **Error Handling**: Implement Result type for better error handling
6. **Logging**: Add comprehensive logging throughout the app

## References

- [Flutter MVVM Architecture](https://docs.flutter.dev/development/data-and-backend/state-mgmt/options#provider)
- [Provider Package](https://pub.dev/packages/provider)
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
