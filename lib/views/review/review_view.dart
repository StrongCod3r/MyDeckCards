import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/review_viewmodel.dart';
import '../../providers/deck_provider.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/review_card_widget.dart';
import 'widgets/review_stats_bar.dart';
import 'widgets/review_complete_dialog.dart';
import 'widgets/review_exit_dialog.dart';
import 'widgets/copy_card_from_review_dialog.dart';

class ReviewView extends StatelessWidget {
  final String deckId;

  const ReviewView({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ReviewViewModel(
        Provider.of<DeckProvider>(context, listen: false),
        deckId,
      ),
      child: const _ReviewViewContent(),
    );
  }
}

class _ReviewViewContent extends StatefulWidget {
  const _ReviewViewContent();

  @override
  State<_ReviewViewContent> createState() => _ReviewViewContentState();
}

class _ReviewViewContentState extends State<_ReviewViewContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _cardAnimation;
  double _dragOffset = 0.0;
  bool _isAnimating = false;
  double _animationDirection = 1.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cardAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleSwipe(bool isCorrect) async {
    if (_isAnimating) return;

    final viewModel = Provider.of<ReviewViewModel>(context, listen: false);
    final wasLastCard = viewModel.isLastCard;

    setState(() {
      _isAnimating = true;
      _dragOffset = 0.0;
      _animationDirection = isCorrect ? 1.0 : -1.0;
    });

    _animationController.forward().then((_) {
      viewModel.handleAnswer(isCorrect);

      if (!wasLastCard) {
        setState(() {
          _dragOffset = 0.0;
          _isAnimating = false;
        });
        _animationController.reset();
      } else {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    final viewModel = Provider.of<ReviewViewModel>(context, listen: false);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ReviewCompleteDialog(
        correctCount: viewModel.correctCount,
        incorrectCount: viewModel.incorrectCount,
        onFinish: () {
          Navigator.pop(ctx);
          Navigator.pop(context);
        },
        onReviewAgain: () {
          Navigator.pop(ctx);
          viewModel.resetReview();
          setState(() {
            _dragOffset = 0.0;
            _isAnimating = false;
          });
          _animationController.reset();
        },
      ),
    );
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (ctx) => const ReviewExitDialog(),
    );
    return shouldPop ?? false;
  }

  void _updateDragOffset(double delta) {
    setState(() {
      _dragOffset += delta;
    });
  }

  void _onDragEnd() {
    if (!_isAnimating) {
      if (_dragOffset.abs() > 100) {
        final isCorrect = _dragOffset > 0;
        final startOffset = _dragOffset;
        setState(() {
          _dragOffset = 0.0;
        });
        _animationController.value = startOffset.abs() / 500;
        _handleSwipe(isCorrect);
      } else {
        setState(() {
          _dragOffset = 0.0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<ReviewViewModel>(
            builder: (context, viewModel, child) {
              final l10n = AppLocalizations.of(context)!;
              return Text(viewModel.deck?.name ?? l10n.translate('review'));
            },
          ),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: [
            Consumer<ReviewViewModel>(
              builder: (context, viewModel, child) {
                final card = viewModel.currentCard;
                if (card == null) return const SizedBox.shrink();

                return PopupMenuButton(
                  icon: const Icon(Icons.more_vert),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'copy',
                      child: Row(
                        children: [
                          const Icon(Icons.content_copy),
                          const SizedBox(width: 8),
                          Text(AppLocalizations.of(context)!.translate('copyCard')),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'copy') {
                      CopyCardFromReviewDialog.show(
                        context,
                        card,
                        viewModel.deckId,
                      );
                    }
                  },
                );
              },
            ),
          ],
        ),
        body: Consumer<ReviewViewModel>(
          builder: (context, viewModel, child) {
            final l10n = AppLocalizations.of(context)!;

            if (!viewModel.hasCards) {
              return Center(child: Text(l10n.translate('noCards')));
            }

            final card = viewModel.currentCard;
            if (card == null) {
              return Center(child: Text(l10n.translate('noCards')));
            }

            return Column(
              children: [
                ReviewStatsBar(
                  currentIndex: viewModel.currentIndex,
                  totalCards: viewModel.cards.length,
                  correctCount: viewModel.correctCount,
                  incorrectCount: viewModel.incorrectCount,
                ),
                Expanded(
                  child: Center(
                    child: ReviewCardWidget(
                      card: card,
                      showBack: viewModel.showBack,
                      dragOffset: _dragOffset,
                      isAnimating: _isAnimating,
                      cardAnimation: _cardAnimation,
                      animationDirection: _animationDirection,
                      onTap: () {
                        if (!_isAnimating && !viewModel.showBack) {
                          viewModel.flipCard();
                        }
                      },
                      onDragUpdate: (delta) {
                        if (!_isAnimating && viewModel.showBack) {
                          _updateDragOffset(delta);
                        }
                      },
                      onDragEnd: () {
                        if (viewModel.showBack) {
                          _onDragEnd();
                        }
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Opacity(
                    opacity: viewModel.showBack ? 1.0 : 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        FloatingActionButton(
                          onPressed: (_isAnimating || !viewModel.showBack)
                              ? null
                              : () => _handleSwipe(false),
                          backgroundColor: Colors.red[400],
                          foregroundColor: Colors.white,
                          heroTag: 'incorrect',
                          child: const Icon(Icons.close, size: 32),
                        ),
                        FloatingActionButton(
                          onPressed: (_isAnimating || !viewModel.showBack)
                              ? null
                              : () => _handleSwipe(true),
                          backgroundColor: Colors.green[400],
                          foregroundColor: Colors.white,
                          heroTag: 'correct',
                          child: const Icon(Icons.check, size: 32),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
