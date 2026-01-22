# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-22

### Added

#### Core Features
- **MVVM Architecture**: Implemented Model-View-ViewModel pattern for clear separation of concerns
- **Deck Management**: Create, rename, and manage flashcard decks
- **Card Management**: Add, edit, and delete flashcards with front and back content
- **Review Mode**: Interactive flashcard review with swipe gestures and tap-to-flip
- **Import/Export**: JSON-based deck import and export functionality
- **Internationalization**: Support for English and Spanish languages
- **Theme Support**: Light, dark, and system-default themes
- **Data Persistence**: SQLite database for local data storage
- **Settings Management**: User preferences for theme and language

#### Advanced Features
- **Deck Icons**: Custom emoji icons for decks (with emoji picker)
- **Archived Decks**: Archive decks instead of deleting them permanently
  - View all archived decks in a dedicated screen
  - Restore archived decks to active status
  - Permanently delete only from archived view
- **Predefined Vocabulary Decks**: Pre-made language learning decks
  - English levels: A1, A2, B1, B2, C1
  - Spanish levels: A1, A2, B1, B2, C1
  - Import predefined decks with a single tap
- **Deck Sorting**: Multiple sort options
  - By name (A-Z, Z-A)
  - By creation date (newest first, oldest first)
  - By card count (most cards, least cards)
  - Sort preference is persisted
- **About Page**: App information with version and developer details

#### User Experience
- **Continuous Card Creation**: Dialog reopens after adding a card for quick bulk entry
- **Quick Edit**: Tap cards directly to edit them
- **Long Press Actions**: Context menus for deck and card operations
- **Screen Awake**: Keep screen on during review sessions (mobile)
- **Exit Confirmation**: Confirm before exiting an active review
- **Progress Tracking**: Real-time score and position tracking during review
- **Review Summary**: Final score screen with option to repeat

#### Technical Features
- **Cross-Platform**: Runs on Android, iOS, Windows, Linux, macOS, and Web
- **Provider State Management**: Efficient state management using Provider package
- **Modular Architecture**: Organized code structure with separate layers
  - Models for data structures
  - ViewModels for business logic
  - Views organized by feature
  - Services for data access
  - Providers for state coordination
- **BaseViewModel**: Common functionality for all ViewModels
  - Loading state management
  - Error handling
  - Async operation execution

#### Import/Export Features
- **JSON Format**: Simple, human-readable export format
- **Conflict Resolution**: Automatic renaming of duplicate deck names on import
- **Timestamp Naming**: Export files named with current date/time
- **Batch Operations**: Export all decks at once
- **Metadata Preservation**: Icon and archived status preserved in export

### Developer Experience
- **Comprehensive Documentation**: 
  - README with feature overview and usage instructions
  - ARCHITECTURE.md with detailed architectural documentation
  - USER_GUIDE.md with complete user instructions
  - CHANGELOG.md for tracking changes
- **Code Organization**: Clear separation of concerns with well-defined layers
- **Type Safety**: Strong typing throughout the codebase
- **Error Handling**: Comprehensive error handling in ViewModels and Services

### Dependencies
- `provider` ^6.1.2 - State management
- `sqflite` ^2.4.1 - SQLite database (mobile)
- `sqflite_common_ffi` ^2.3.4 - SQLite database (desktop)
- `uuid` ^4.5.1 - Unique identifier generation
- `wakelock_plus` ^1.2.8 - Keep screen on during review
- `file_picker` ^8.1.6 - File selection for import
- `path_provider` ^2.1.5 - System directory access
- `shared_preferences` ^2.3.4 - Settings persistence
- `package_info_plus` (for future version display)
- `flutter_localizations` - Internationalization support
- `intl` - Internationalization utilities

### Initial Release Notes

This is the initial release of MyDeckCards, a cross-platform flashcard application built with Flutter. The app provides a complete flashcard learning experience with modern features like archiving, predefined decks, and comprehensive import/export capabilities.

Key highlights:
- ✅ Full MVVM architecture for maintainability
- ✅ Multi-language support (English and Spanish)
- ✅ Cross-platform compatibility
- ✅ Offline-first design with local data persistence
- ✅ User-friendly interface with material design
- ✅ Pre-made language learning content included
- ✅ Flexible data management with archive feature

## [Unreleased]

### Planned Features

#### Short Term (v0.2.0)
- [ ] Spaced repetition algorithm (SRS)
- [ ] Study statistics and analytics
- [ ] Deck tags/categories
- [ ] Search functionality for decks and cards
- [ ] Card scheduling based on performance
- [ ] Multiple choice review mode
- [ ] Bulk card import from CSV/Excel

#### Medium Term (v0.3.0)
- [ ] Cloud synchronization
- [ ] Deck sharing community
- [ ] Image support for cards
- [ ] Audio pronunciation for language decks
- [ ] Study reminders/notifications
- [ ] Achievement system
- [ ] Study streaks tracking

#### Long Term (v1.0.0)
- [ ] Collaborative decks
- [ ] AI-powered card generation
- [ ] Integration with popular language learning APIs
- [ ] Advanced statistics and progress charts
- [ ] Customizable review algorithms
- [ ] Plugin system for extensions
- [ ] Web version with full feature parity

### Under Consideration
- [ ] Video content support
- [ ] Handwriting input for practice
- [ ] Voice recognition for language learning
- [ ] Gamification features
- [ ] Social features (friends, leaderboards)
- [ ] Export to Anki format
- [ ] Import from Quizlet

## Version History

### v0.1.0 (2025-01-22)
- Initial release with core functionality
- Full deck and card management
- Review mode with progress tracking
- Import/export with JSON format
- Archive feature for deck organization
- Predefined vocabulary decks (English and Spanish)
- Multi-language UI support
- Theme customization
- Cross-platform support

---

## Migration Notes

### From v0.0.x to v0.1.0

This is the initial stable release. If you have been using development versions:

1. **Database Schema Changes**: 
   - Added `archived` column to decks table
   - Added `icon` column to decks table
   
2. **Data Migration**: 
   - Export your decks from the old version
   - Install v0.1.0
   - Import your decks
   - Archived status defaults to `false` for imported decks
   - Icon defaults to `📚` if not specified

3. **Settings Changes**:
   - Sort order preference is now persisted
   - Default sort is now by name (A-Z)

## Contributing

Found a bug or have a feature request? Please open an issue on the GitHub repository.

Want to contribute code? Pull requests are welcome! Please follow the existing code style and architecture patterns.

## License

Copyright © 2025 SC.

---

**Note**: This changelog follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) guidelines and uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
