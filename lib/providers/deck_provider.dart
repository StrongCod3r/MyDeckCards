import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';
import '../services/database_service.dart';

class DeckProvider extends ChangeNotifier {
  List<Deck> _decks = [];
  final Uuid _uuid = const Uuid();
  final DatabaseService _db = DatabaseService.instance;

  List<Deck> get decks => _decks;

  Future<void> loadDecks() async {
    _decks = await _db.getAllDecks();
    notifyListeners();
  }

  Future<void> addDeck(String name) async {
    final newDeck = Deck(id: _uuid.v4(), name: name);
    await _db.insertDeck(newDeck);
    _decks.insert(0, newDeck);
    notifyListeners();
  }

  Future<void> updateDeckName(String deckId, String newName) async {
    final index = _decks.indexWhere((deck) => deck.id == deckId);
    if (index != -1) {
      _decks[index] = _decks[index].copyWith(name: newName);
      await _db.updateDeck(_decks[index]);
      notifyListeners();
    }
  }

  Future<void> updateDeckIcon(String deckId, String? newIcon) async {
    final index = _decks.indexWhere((deck) => deck.id == deckId);
    if (index != -1) {
      _decks[index] = _decks[index].copyWith(icon: newIcon);
      await _db.updateDeck(_decks[index]);
      notifyListeners();
    }
  }

  Future<void> archiveDeck(String deckId) async {
    final index = _decks.indexWhere((deck) => deck.id == deckId);
    if (index != -1) {
      _decks[index] = _decks[index].copyWith(archived: true);
      await _db.updateDeck(_decks[index]);
      notifyListeners();
    }
  }

  Future<void> unarchiveDeck(String deckId) async {
    final index = _decks.indexWhere((deck) => deck.id == deckId);
    if (index != -1) {
      _decks[index] = _decks[index].copyWith(archived: false);
      await _db.updateDeck(_decks[index]);
      notifyListeners();
    }
  }

  Future<void> deleteDeck(String deckId) async {
    await _db.deleteDeck(deckId);
    _decks.removeWhere((deck) => deck.id == deckId);
    notifyListeners();
  }

  Future<void> addCard(String deckId, String front, String back) async {
    final index = _decks.indexWhere((deck) => deck.id == deckId);
    if (index != -1) {
      final newCard = Flashcard(id: _uuid.v4(), front: front, back: back);
      await _db.insertCard(deckId, newCard);
      final updatedCards = List<Flashcard>.from(_decks[index].cards)
        ..insert(0, newCard);
      _decks[index] = _decks[index].copyWith(cards: updatedCards);
      notifyListeners();
    }
  }

  Future<void> deleteCard(String deckId, String cardId) async {
    await _db.deleteCard(cardId);
    final index = _decks.indexWhere((deck) => deck.id == deckId);
    if (index != -1) {
      final updatedCards = _decks[index].cards
          .where((card) => card.id != cardId)
          .toList();
      _decks[index] = _decks[index].copyWith(cards: updatedCards);
      notifyListeners();
    }
  }

  Future<void> updateCard(
    String deckId,
    String cardId,
    String front,
    String back,
  ) async {
    final deckIndex = _decks.indexWhere((deck) => deck.id == deckId);
    if (deckIndex != -1) {
      final cardIndex = _decks[deckIndex].cards.indexWhere(
        (card) => card.id == cardId,
      );
      if (cardIndex != -1) {
        final updatedCards = List<Flashcard>.from(_decks[deckIndex].cards);
        updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(
          front: front,
          back: back,
        );
        await _db.updateCard(updatedCards[cardIndex], deckId);
        _decks[deckIndex] = _decks[deckIndex].copyWith(cards: updatedCards);
        notifyListeners();
      }
    }
  }

  Deck? getDeck(String deckId) {
    try {
      return _decks.firstWhere((deck) => deck.id == deckId);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isDeckNameUnique(String name, {String? excludeDeckId}) async {
    return await _db.isDeckNameUnique(name, excludeDeckId: excludeDeckId);
  }

  Future<bool> isCardFrontUnique(
    String deckId,
    String front, {
    String? excludeCardId,
  }) async {
    return await _db.isCardFrontUnique(
      deckId,
      front,
      excludeCardId: excludeCardId,
    );
  }

  Future<void> moveCard(
    String cardId,
    String sourceDeckId,
    String destinationDeckId,
  ) async {
    final sourceIndex = _decks.indexWhere((deck) => deck.id == sourceDeckId);
    final destIndex = _decks.indexWhere((deck) => deck.id == destinationDeckId);

    if (sourceIndex != -1 && destIndex != -1) {
      // Find the card in the source deck
      final card = _decks[sourceIndex].cards.firstWhere((c) => c.id == cardId);

      // Remove from source deck
      await _db.deleteCard(cardId);
      final updatedSourceCards = _decks[sourceIndex].cards
          .where((c) => c.id != cardId)
          .toList();
      _decks[sourceIndex] = _decks[sourceIndex].copyWith(
        cards: updatedSourceCards,
      );

      // Add to destination deck
      await _db.insertCard(destinationDeckId, card);
      final updatedDestCards = List<Flashcard>.from(_decks[destIndex].cards)
        ..insert(0, card);
      _decks[destIndex] = _decks[destIndex].copyWith(cards: updatedDestCards);

      notifyListeners();
    }
  }

  Future<void> copyCard(
    String cardId,
    String sourceDeckId,
    String destinationDeckId,
  ) async {
    final sourceIndex = _decks.indexWhere((deck) => deck.id == sourceDeckId);
    final destIndex = _decks.indexWhere((deck) => deck.id == destinationDeckId);

    if (sourceIndex != -1 && destIndex != -1) {
      // Find the card in the source deck
      final originalCard = _decks[sourceIndex].cards.firstWhere(
        (c) => c.id == cardId,
      );

      // Create a new card with a new ID
      final copiedCard = Flashcard(
        id: _uuid.v4(),
        front: originalCard.front,
        back: originalCard.back,
      );

      // Add to destination deck
      await _db.insertCard(destinationDeckId, copiedCard);
      final updatedDestCards = List<Flashcard>.from(_decks[destIndex].cards)
        ..insert(0, copiedCard);
      _decks[destIndex] = _decks[destIndex].copyWith(cards: updatedDestCards);

      notifyListeners();
    }
  }
}
