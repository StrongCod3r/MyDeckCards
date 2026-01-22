import '../models/deck.dart';
import '../providers/deck_provider.dart';
import '../providers/settings_provider.dart';
import 'base_viewmodel.dart';

/// ViewModel for the Home screen
class HomeViewModel extends BaseViewModel {
  final DeckProvider _deckProvider;
  SortOrder? _sortOrder;

  HomeViewModel(this._deckProvider) {
    _deckProvider.addListener(_onDeckProviderChanged);
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  List<Deck> get decks => _deckProvider.decks;

  List<Deck> get activeDecks {
    final decks = _deckProvider.decks.where((deck) => !deck.archived).toList();
    return _sortDecks(decks);
  }

  List<Deck> get archivedDecks {
    final decks = _deckProvider.decks.where((deck) => deck.archived).toList();
    return _sortDecks(decks);
  }

  List<Deck> _sortDecks(List<Deck> decks) {
    if (_sortOrder == null) return decks;
    
    final sortedDecks = List<Deck>.from(decks);
    switch (_sortOrder!) {
      case SortOrder.nameAsc:
        sortedDecks.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
      case SortOrder.nameDesc:
        sortedDecks.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
        break;
      case SortOrder.dateCreated:
        sortedDecks.sort((a, b) => b.id.compareTo(a.id));
        break;
    }
    return sortedDecks;
  }

  void _onDeckProviderChanged() {
    notifyListeners();
  }

  /// Add a new deck
  Future<bool> addDeck(String name) async {
    if (name.isEmpty) {
      setError('deckNameRequired');
      return false;
    }

    final isUnique = await _deckProvider.isDeckNameUnique(name);
    if (!isUnique) {
      setError('deckNameExists');
      return false;
    }

    clearError();
    await _deckProvider.addDeck(name);
    return true;
  }

  /// Rename a deck
  Future<bool> renameDeck(
    String deckId,
    String currentName,
    String newName,
  ) async {
    if (newName.isEmpty) {
      setError('deckNameRequired');
      return false;
    }

    if (newName == currentName) {
      return true;
    }

    final isUnique = await _deckProvider.isDeckNameUnique(newName);
    if (!isUnique) {
      setError('deckNameExists');
      return false;
    }

    clearError();
    await _deckProvider.updateDeckName(deckId, newName);
    return true;
  }

  /// Update deck icon
  Future<void> updateDeckIcon(String deckId, String? icon) async {
    await _deckProvider.updateDeckIcon(deckId, icon);
  }

  /// Archive a deck
  Future<void> archiveDeck(String deckId) async {
    await _deckProvider.archiveDeck(deckId);
  }

  /// Unarchive a deck
  Future<void> unarchiveDeck(String deckId) async {
    await _deckProvider.unarchiveDeck(deckId);
  }

  /// Delete a deck
  Future<void> deleteDeck(String deckId) async {
    await _deckProvider.deleteDeck(deckId);
  }

  /// Export all decks to JSON
  Future<Map<String, dynamic>> exportDecks() async {
    final exportData = {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'decks': decks
          .map(
            (deck) => {
              'name': deck.name,
              if (deck.icon != null) 'icon': deck.icon,
              'cards': deck.cards
                  .map((card) => {'front': card.front, 'back': card.back})
                  .toList(),
            },
          )
          .toList(),
    };

    return exportData;
  }

  /// Import decks from JSON
  Future<Map<String, dynamic>> importDecks(
    Map<String, dynamic> jsonData,
  ) async {
    if (jsonData['decks'] == null || jsonData['decks'] is! List) {
      throw Exception('invalidJson');
    }

    final List decks = jsonData['decks'];
    int importedDecks = 0;
    int totalCards = 0;
    int renamedDecks = 0;

    for (var deckData in decks) {
      String deckName = deckData['name'] ?? 'Untitled';
      final String? deckIcon = deckData['icon'] as String?;
      final cards = (deckData['cards'] as List?) ?? [];

      // Check for name conflicts
      bool isUnique = await _deckProvider.isDeckNameUnique(deckName);
      if (!isUnique) {
        int counter = 1;
        String baseName = deckName;
        while (!isUnique) {
          deckName = '$baseName ($counter)';
          isUnique = await _deckProvider.isDeckNameUnique(deckName);
          counter++;
        }
        renamedDecks++;
      }

      // Create deck
      await _deckProvider.addDeck(deckName);
      final newDeck = _deckProvider.decks.firstWhere((d) => d.name == deckName);

      // Set icon if provided
      if (deckIcon != null) {
        await _deckProvider.updateDeckIcon(newDeck.id, deckIcon);
      }

      // Add cards
      for (var cardData in cards) {
        final front = cardData['front'] ?? '';
        final back = cardData['back'] ?? '';
        if (front.isNotEmpty && back.isNotEmpty) {
          await _deckProvider.addCard(newDeck.id, front, back);
          totalCards++;
        }
      }

      importedDecks++;
    }

    return {
      'deckCount': importedDecks,
      'cardCount': totalCards,
      'renamedCount': renamedDecks,
    };
  }

  @override
  void dispose() {
    _deckProvider.removeListener(_onDeckProviderChanged);
    super.dispose();
  }
}
