# Contributing to MyDeckCards

Thank you for considering contributing to MyDeckCards! This document provides guidelines and information for contributors.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Setup](#development-setup)
4. [Architecture Overview](#architecture-overview)
5. [Coding Standards](#coding-standards)
6. [Submitting Changes](#submitting-changes)
7. [Testing Guidelines](#testing-guidelines)
8. [Documentation](#documentation)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of experience level, background, or identity.

### Expected Behavior

- Be respectful and considerate
- Welcome newcomers and help them get started
- Focus on constructive feedback
- Accept responsibility and apologize for mistakes
- Keep discussions focused on the project

### Unacceptable Behavior

- Harassment, discrimination, or offensive comments
- Trolling, insulting, or derogatory remarks
- Publishing others' private information
- Other conduct inappropriate for a professional setting

## Getting Started

### Prerequisites

- **Flutter SDK**: 3.10.3 or higher
- **Dart SDK**: Included with Flutter
- **Git**: For version control
- **IDE**: VS Code or Android Studio (recommended)

### Recommended Extensions (VS Code)

- Flutter & Dart extensions
- Error Lens
- Dart Data Class Generator
- Flutter Intl

## Development Setup

### 1. Fork and Clone

```bash
# Fork the repository on GitHub
git clone https://github.com/YOUR_USERNAME/mydeckcards.git
cd mydeckcards
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Run the App

```bash
# For development
flutter run

# For specific platform
flutter run -d windows
flutter run -d chrome
flutter run -d <device_id>
```

### 4. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/bug-description
```

## Architecture Overview

MyDeckCards follows the **MVVM (Model-View-ViewModel)** pattern. Please read [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) for detailed information.

### Quick Summary

```
┌─────────────────────────────────────┐
│  View (UI)                          │
│  - Flutter widgets                  │
│  - No business logic                │
└──────────────┬──────────────────────┘
               │ Observes
               ▼
┌─────────────────────────────────────┐
│  ViewModel (Logic)                  │
│  - Business logic                   │
│  - Validation                       │
│  - State management                 │
└──────────────┬──────────────────────┘
               │ Uses
               ▼
┌─────────────────────────────────────┐
│  Provider (State)                   │
│  - Data coordination                │
│  - Multi-view state                 │
└──────────────┬──────────────────────┘
               │ Uses
               ▼
┌─────────────────────────────────────┐
│  Service (Data Access)              │
│  - Database operations              │
│  - File operations                  │
└──────────────┬──────────────────────┘
               │ Operates on
               ▼
┌─────────────────────────────────────┐
│  Model (Data)                       │
│  - Data structures                  │
│  - Serialization                    │
└─────────────────────────────────────┘
```

### Layer Rules

1. **Views** can only call **ViewModels**
2. **ViewModels** can call **Providers** and use **Models**
3. **Providers** can call **Services** and use **Models**
4. **Services** can only use **Models**
5. **Models** have no dependencies

## Coding Standards

### Dart Style

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style).

```bash
# Format code
dart format .

# Analyze code
flutter analyze
```

### Naming Conventions

#### Files
- `snake_case.dart` for file names
- Match class name: `MyWidget` → `my_widget.dart`

#### Classes
- `PascalCase` for class names
- Descriptive names: `HomeViewModel`, `DeckProvider`

#### Variables and Functions
- `camelCase` for variables and functions
- Private members prefixed with `_`: `_privateMethod()`
- Boolean variables: `isLoading`, `hasError`, `canEdit`

#### Constants
- `camelCase` for const variables
- `SCREAMING_SNAKE_CASE` for static const

### Code Organization

#### Import Order
```dart
// 1. Dart imports
import 'dart:async';
import 'dart:io';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. Package imports
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

// 4. Relative imports
import '../../models/deck.dart';
import '../../services/database_service.dart';
import '../widgets/deck_card.dart';
```

#### File Structure
```dart
// Imports (grouped as above)
import 'package:flutter/material.dart';

// Constants (if any)
const kDefaultDeckIcon = '📚';

// Main class
class MyWidget extends StatelessWidget {
  // Public fields
  final String title;
  
  // Private fields
  final String? _subtitle;
  
  // Constructor
  const MyWidget({
    super.key,
    required this.title,
    String? subtitle,
  }) : _subtitle = subtitle;
  
  // Public methods
  @override
  Widget build(BuildContext context) {
    return Container();
  }
  
  // Private methods
  void _handleTap() {
    // Implementation
  }
}

// Helper classes/functions (if needed)
class _HelperClass {
  // Implementation
}
```

### Widget Guidelines

#### Prefer Stateless Widgets
```dart
// Good
class MyWidget extends StatelessWidget {
  const MyWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

// Avoid (unless state is truly needed)
class MyWidget extends StatefulWidget {
  // ...
}
```

#### Use const Constructors
```dart
// Good
const Text('Hello'),
const SizedBox(height: 16),

// Avoid
Text('Hello'),
SizedBox(height: 16),
```

#### Extract Complex Widgets
```dart
// Good
class ComplexFeature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        _buildContent(),
        _buildFooter(),
      ],
    );
  }
  
  Widget _buildHeader() {
    return Container(/* ... */);
  }
}

// Avoid
class ComplexFeature extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(/* 50 lines of code */),
        Container(/* 50 lines of code */),
        Container(/* 50 lines of code */),
      ],
    );
  }
}
```

### ViewModel Guidelines

#### Extend BaseViewModel
```dart
class MyViewModel extends BaseViewModel {
  final MyProvider _provider;
  
  MyViewModel(this._provider);
  
  // Use executeAsync for async operations
  Future<void> performAction() async {
    await executeAsync(() async {
      await _provider.doSomething();
    });
  }
}
```

#### Handle Errors Properly
```dart
// Good
Future<void> saveDeck(String name) async {
  if (name.trim().isEmpty) {
    throw ValidationException('Name cannot be empty');
  }
  
  await executeAsync(() async {
    await _provider.saveDeck(name.trim());
  });
}

// Avoid
Future<void> saveDeck(String name) async {
  await _provider.saveDeck(name);
}
```

### Provider Guidelines

#### Notify Listeners After Changes
```dart
class DeckProvider extends ChangeNotifier {
  List<Deck> _decks = [];
  
  Future<void> addDeck(Deck deck) async {
    await _databaseService.insertDeck(deck);
    _decks.add(deck);
    notifyListeners(); // Always notify after state change
  }
}
```

#### Keep Providers Focused
```dart
// Good - Focused responsibility
class DeckProvider extends ChangeNotifier {
  // Only deck-related operations
}

class SettingsProvider extends ChangeNotifier {
  // Only settings-related operations
}

// Avoid - Too many responsibilities
class AppProvider extends ChangeNotifier {
  // Decks, settings, user data, etc.
}
```

## Submitting Changes

### 1. Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <subject>

<body>

<footer>
```

#### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

#### Examples
```
feat(deck): add archive functionality

Implement deck archiving to allow users to hide decks without deleting them.

- Add archived field to Deck model
- Add archive/unarchive methods to DeckProvider
- Create ArchivedDecksView
- Update database schema

Closes #123
```

```
fix(review): prevent multiple card flips

Cards can now only be flipped once during review to maintain integrity.

Fixes #456
```

```
docs(architecture): add MVVM documentation

Created comprehensive architecture documentation explaining the MVVM pattern and how it's implemented in the app.
```

### 2. Pull Request Process

#### Before Creating PR
1. Update your branch with latest main:
   ```bash
   git checkout main
   git pull upstream main
   git checkout your-branch
   git rebase main
   ```

2. Run tests and checks:
   ```bash
   flutter analyze
   flutter test
   dart format .
   ```

3. Update documentation if needed

#### PR Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Tested on Desktop
- [ ] Added/updated tests

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-reviewed the code
- [ ] Commented complex code sections
- [ ] Updated documentation
- [ ] No new warnings
- [ ] Tests pass locally

## Screenshots (if applicable)
Add screenshots for UI changes

## Related Issues
Closes #issue_number
```

### 3. Review Process

- At least one approval required
- All CI checks must pass
- Address review comments
- Keep PR scope focused

## Testing Guidelines

### Unit Tests

Test ViewModels and Services:

```dart
// test/viewmodels/home_viewmodel_test.dart
void main() {
  group('HomeViewModel', () {
    late HomeViewModel viewModel;
    late MockDeckProvider mockProvider;
    
    setUp(() {
      mockProvider = MockDeckProvider();
      viewModel = HomeViewModel(mockProvider);
    });
    
    test('sorts decks by name ascending', () {
      // Arrange
      final decks = [
        Deck(id: '1', name: 'Zebra'),
        Deck(id: '2', name: 'Apple'),
      ];
      when(mockProvider.activeDecks).thenReturn(decks);
      
      // Act
      viewModel.setSortOrder(SortOrder.nameAsc);
      
      // Assert
      expect(viewModel.decks[0].name, 'Apple');
      expect(viewModel.decks[1].name, 'Zebra');
    });
  });
}
```

### Widget Tests

Test UI components:

```dart
// test/widgets/deck_card_test.dart
void main() {
  testWidgets('DeckCard displays deck information', (tester) async {
    // Arrange
    final deck = Deck(
      id: '1',
      name: 'Test Deck',
      icon: '📚',
      cards: [Flashcard(/* ... */)],
    );
    
    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeckCard(deck: deck),
        ),
      ),
    );
    
    // Assert
    expect(find.text('Test Deck'), findsOneWidget);
    expect(find.text('📚'), findsOneWidget);
    expect(find.text('1 card'), findsOneWidget);
  });
}
```

### Integration Tests

Test complete flows:

```bash
flutter test integration_test/
```

### Running Tests

```bash
# All tests
flutter test

# Specific file
flutter test test/viewmodels/home_viewmodel_test.dart

# With coverage
flutter test --coverage
```

## Documentation

### Code Comments

#### When to Comment
- Complex algorithms or business logic
- Non-obvious decisions
- TODO items for future improvements
- Public API documentation

#### When NOT to Comment
- Obvious code
- Repeating what the code does
- Commented-out code (delete it instead)

#### Examples

```dart
// Good - Explains WHY
// Cards must be shuffled before review to ensure random distribution
// as per spaced repetition algorithm requirements
final shuffledCards = _shuffleCards(deck.cards);

// Good - Public API documentation
/// Creates a new deck with the given [name] and optional [icon].
/// 
/// Throws [ValidationException] if [name] is empty.
/// 
/// Example:
/// ```dart
/// await provider.createDeck('My Deck', '📚');
/// ```
Future<void> createDeck(String name, String? icon);

// Avoid - States the obvious
// Increment counter by 1
counter++;

// Avoid - Commented out code (use version control instead)
// void oldMethod() {
//   // old implementation
// }
```

### Updating Documentation

When making changes, update relevant documentation:

1. **README.md**: User-facing features
2. **docs/ARCHITECTURE.md**: Architectural changes
3. **docs/USER_GUIDE.md**: User instructions
4. **CHANGELOG.md**: All changes
5. **Code comments**: Complex implementations

## Feature Development Workflow

### 1. Planning
- Open an issue describing the feature
- Discuss approach and design
- Get approval before starting

### 2. Implementation
- Create feature branch
- Implement following MVVM pattern
- Write tests
- Update documentation

### 3. Testing
- Test on multiple platforms
- Verify existing features still work
- Add automated tests

### 4. Review
- Create pull request
- Address review comments
- Update based on feedback

### 5. Merge
- Ensure CI passes
- Squash commits if needed
- Merge to main

## Common Tasks

### Adding a New Feature

1. **Create Model** (if needed)
   ```dart
   // lib/models/my_feature.dart
   class MyFeature {
     final String id;
     final String name;
     
     MyFeature({required this.id, required this.name});
     
     Map<String, dynamic> toJson() => {'id': id, 'name': name};
     factory MyFeature.fromJson(Map<String, dynamic> json) => 
       MyFeature(id: json['id'], name: json['name']);
   }
   ```

2. **Create Service** (if needed)
   ```dart
   // lib/services/my_feature_service.dart
   class MyFeatureService {
     Future<void> saveFeature(MyFeature feature) async {
       // Implementation
     }
   }
   ```

3. **Create Provider**
   ```dart
   // lib/providers/my_feature_provider.dart
   class MyFeatureProvider extends ChangeNotifier {
     final MyFeatureService _service;
     
     MyFeatureProvider(this._service);
     
     Future<void> addFeature(MyFeature feature) async {
       await _service.saveFeature(feature);
       notifyListeners();
     }
   }
   ```

4. **Create ViewModel**
   ```dart
   // lib/viewmodels/my_feature_viewmodel.dart
   class MyFeatureViewModel extends BaseViewModel {
     final MyFeatureProvider _provider;
     
     MyFeatureViewModel(this._provider);
     
     Future<void> createFeature(String name) async {
       await executeAsync(() async {
         final feature = MyFeature(id: Uuid().v4(), name: name);
         await _provider.addFeature(feature);
       });
     }
   }
   ```

5. **Create View**
   ```dart
   // lib/views/my_feature/my_feature_view.dart
   class MyFeatureView extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return ChangeNotifierProvider(
         create: (_) => MyFeatureViewModel(
           Provider.of<MyFeatureProvider>(context, listen: false),
         ),
         child: Consumer<MyFeatureViewModel>(
           builder: (context, viewModel, _) {
             // UI implementation
           },
         ),
       );
     }
   }
   ```

### Adding Internationalization

1. **Add translations** in `lib/l10n/app_localizations.dart`:
   ```dart
   static final Map<String, Map<String, String>> _localizedValues = {
     'en': {
       'myNewKey': 'My English Text',
     },
     'es': {
       'myNewKey': 'Mi Texto en Español',
     },
   };
   ```

2. **Use in code**:
   ```dart
   Text(l10n.translate('myNewKey'))
   ```

## Questions?

- Open an issue for questions
- Join discussions in existing issues
- Check documentation in `/docs` folder

## Thank You!

Thank you for contributing to MyDeckCards! Your efforts help make this project better for everyone.

---

**Happy Coding!** 🎉
