import '../models/deck.dart';
import '../models/flashcard.dart';
import '../providers/deck_provider.dart';
import '../providers/settings_provider.dart';
import 'base_viewmodel.dart';

/// ViewModel for the Deck Detail screen
class DeckDetailViewModel extends BaseViewModel {
  final DeckProvider _deckProvider;
  final String deckId;
  SortOrder? _sortOrder;
  
  // Selection mode
  bool _isSelectionMode = false;
  final Set<String> _selectedCardIds = {};

  DeckDetailViewModel(this._deckProvider, this.deckId) {
    _deckProvider.addListener(_onDeckProviderChanged);
  }

  void setSortOrder(SortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  Deck? get deck => _deckProvider.getDeck(deckId);
  
  List<Flashcard> get cards {
    final cardsList = deck?.cards ?? [];
    if (_sortOrder == null) return cardsList;
    
    final sortedCards = List<Flashcard>.from(cardsList);
    switch (_sortOrder!) {
      case SortOrder.nameAsc:
        sortedCards.sort((a, b) => a.front.toLowerCase().compareTo(b.front.toLowerCase()));
        break;
      case SortOrder.nameDesc:
        sortedCards.sort((a, b) => b.front.toLowerCase().compareTo(a.front.toLowerCase()));
        break;
      case SortOrder.dateCreated:
        sortedCards.sort((a, b) => b.id.compareTo(a.id));
        break;
    }
    return sortedCards;
  }
  
  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedCardIds => _selectedCardIds;
  int get selectedCount => _selectedCardIds.length;
  
  void toggleSelectionMode() {
    _isSelectionMode = !_isSelectionMode;
    if (!_isSelectionMode) {
      _selectedCardIds.clear();
    }
    notifyListeners();
  }
  
  void toggleCardSelection(String cardId) {
    if (_selectedCardIds.contains(cardId)) {
      _selectedCardIds.remove(cardId);
    } else {
      _selectedCardIds.add(cardId);
    }
    notifyListeners();
  }
  
  void selectAll() {
    _selectedCardIds.clear();
    _selectedCardIds.addAll(cards.map((c) => c.id));
    notifyListeners();
  }
  
  void clearSelection() {
    _selectedCardIds.clear();
    notifyListeners();
  }

  void _onDeckProviderChanged() {
    notifyListeners();
  }

  /// Add a new card to the deck
  Future<bool> addCard(String front, String back) async {
    if (front.isEmpty) {
      setError('frontRequired');
      return false;
    }

    if (back.isEmpty) {
      setError('backRequired');
      return false;
    }

    final isUnique = await _deckProvider.isCardFrontUnique(deckId, front);
    if (!isUnique) {
      setError('cardExists');
      return false;
    }

    clearError();
    await _deckProvider.addCard(deckId, front, back);
    return true;
  }

  /// Update an existing card
  Future<bool> updateCard(String cardId, String front, String back) async {
    if (front.isEmpty) {
      setError('frontRequired');
      return false;
    }

    if (back.isEmpty) {
      setError('backRequired');
      return false;
    }

    final card = cards.firstWhere((c) => c.id == cardId);
    if (card.front != front) {
      final isUnique = await _deckProvider.isCardFrontUnique(deckId, front);
      if (!isUnique) {
        setError('cardExists');
        return false;
      }
    }

    clearError();
    await _deckProvider.updateCard(deckId, cardId, front, back);
    return true;
  }

  /// Delete a card from the deck
  Future<void> deleteCard(String cardId) async {
    await _deckProvider.deleteCard(deckId, cardId);
  }

  /// Delete multiple cards from the deck
  Future<void> deleteMultipleCards(List<String> cardIds) async {
    for (final cardId in cardIds) {
      await _deckProvider.deleteCard(deckId, cardId);
    }
    clearSelection();
    toggleSelectionMode();
  }

  /// Move a card to another deck
  Future<void> moveCard(String cardId, String destinationDeckId) async {
    await _deckProvider.moveCard(cardId, deckId, destinationDeckId);
  }

  /// Copy a card to another deck
  Future<void> copyCard(String cardId, String destinationDeckId) async {
    await _deckProvider.copyCard(cardId, deckId, destinationDeckId);
  }
  
  /// Move multiple cards to another deck
  Future<Map<String, dynamic>> moveMultipleCards(List<String> cardIds, String destinationDeckId) async {
    final conflicts = <Flashcard>[];
    final cardsToMove = <Flashcard>[];
    
    for (final cardId in cardIds) {
      final card = cards.firstWhere((c) => c.id == cardId);
      final isUnique = await _deckProvider.isCardFrontUnique(
        destinationDeckId,
        card.front,
      );
      
      if (!isUnique) {
        conflicts.add(card);
      } else {
        cardsToMove.add(card);
      }
    }
    
    return {
      'conflicts': conflicts,
      'cardsToMove': cardsToMove,
    };
  }
  
  /// Execute move of multiple cards (after confirmation)
  Future<void> executeMoveMultiple(List<String> cardIds, String destinationDeckId) async {
    for (final cardId in cardIds) {
      await _deckProvider.moveCard(cardId, deckId, destinationDeckId);
    }
    _selectedCardIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }
  
  /// Copy multiple cards to another deck
  Future<Map<String, dynamic>> copyMultipleCards(List<String> cardIds, String destinationDeckId) async {
    final conflicts = <Flashcard>[];
    final cardsToCopy = <Flashcard>[];
    
    for (final cardId in cardIds) {
      final card = cards.firstWhere((c) => c.id == cardId);
      final isUnique = await _deckProvider.isCardFrontUnique(
        destinationDeckId,
        card.front,
      );
      
      if (!isUnique) {
        conflicts.add(card);
      } else {
        cardsToCopy.add(card);
      }
    }
    
    return {
      'conflicts': conflicts,
      'cardsToCopy': cardsToCopy,
    };
  }
  
  /// Execute copy of multiple cards (after confirmation)
  Future<void> executeCopyMultiple(List<String> cardIds, String destinationDeckId) async {
    for (final cardId in cardIds) {
      await _deckProvider.copyCard(cardId, deckId, destinationDeckId);
    }
    _selectedCardIds.clear();
    _isSelectionMode = false;
    notifyListeners();
  }

  /// Get all available decks except the current one
  List<Deck> getOtherDecks() {
    return _deckProvider.decks.where((d) => d.id != deckId).toList();
  }

  @override
  void dispose() {
    _deckProvider.removeListener(_onDeckProviderChanged);
    super.dispose();
  }
}
