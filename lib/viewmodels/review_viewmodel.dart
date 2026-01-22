import '../models/deck.dart';
import '../models/flashcard.dart';
import '../providers/deck_provider.dart';
import 'base_viewmodel.dart';

/// ViewModel for the Review screen
class ReviewViewModel extends BaseViewModel {
  final DeckProvider _deckProvider;
  final String deckId;

  int _currentIndex = 0;
  bool _showBack = false;
  int _correctCount = 0;
  int _incorrectCount = 0;

  ReviewViewModel(this._deckProvider, this.deckId) {
    _deckProvider.addListener(_onDeckProviderChanged);
  }

  Deck? get deck => _deckProvider.getDeck(deckId);
  List<Flashcard> get cards => deck?.cards ?? [];

  int get currentIndex => _currentIndex;
  bool get showBack => _showBack;
  int get correctCount => _correctCount;
  int get incorrectCount => _incorrectCount;

  Flashcard? get currentCard =>
      cards.isNotEmpty && _currentIndex < cards.length ? cards[_currentIndex] : null;

  bool get isLastCard => _currentIndex >= cards.length - 1;
  bool get hasCards => cards.isNotEmpty;

  void _onDeckProviderChanged() {
    notifyListeners();
  }

  /// Flip the card to show/hide the back
  void flipCard() {
    if (!_showBack) {
      _showBack = true;
      notifyListeners();
    }
  }

  /// Handle answer (correct or incorrect)
  void handleAnswer(bool isCorrect) {
    if (!_showBack) return;

    if (isCorrect) {
      _correctCount++;
    } else {
      _incorrectCount++;
    }

    if (_currentIndex < cards.length - 1) {
      _currentIndex++;
      _showBack = false;
      notifyListeners();
    } else {
      // Review completed
      notifyListeners();
    }
  }

  /// Reset review to start over
  void resetReview() {
    _currentIndex = 0;
    _showBack = false;
    _correctCount = 0;
    _incorrectCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _deckProvider.removeListener(_onDeckProviderChanged);
    super.dispose();
  }
}
