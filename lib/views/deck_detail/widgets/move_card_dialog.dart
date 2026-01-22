import 'package:flutter/material.dart';
import '../../../models/flashcard.dart';
import '../../../viewmodels/deck_detail_viewmodel.dart';
import '../../../l10n/app_localizations.dart';

class MoveCardDialog {
  static void showSingle(
    BuildContext context,
    DeckDetailViewModel viewModel,
    Flashcard card,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final otherDecks = viewModel.getOtherDecks();

    if (otherDecks.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('emptyDecks')),
          persist: false,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('moveCardTitle')),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.translate('selectDestinationDeck')),
                const SizedBox(height: 16),
                ...otherDecks.map(
                  (deck) => ListTile(
                    leading: Icon(
                      Icons.style,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(deck.name),
                    subtitle: Text(
                      l10n.translate(
                        'cardsCount',
                        params: {'count': deck.cards.length},
                      ),
                    ),
                    onTap: () {
                      viewModel.moveCard(card.id, deck.id);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.translate('cardMoved')),
                          persist: false,
                          duration: const Duration(seconds: 3),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
        ],
      ),
    );
  }

  static void showMultiple(
    BuildContext context,
    DeckDetailViewModel viewModel,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final otherDecks = viewModel.getOtherDecks();

    if (otherDecks.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(l10n.translate('emptyDecks')),
          persist: false,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('moveCardTitle')),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.translate('selectDestinationDeck')),
                const SizedBox(height: 16),
                ...otherDecks.map(
                  (deck) => ListTile(
                    leading: deck.icon != null
                        ? Text(deck.icon!, style: const TextStyle(fontSize: 24))
                        : Icon(
                            Icons.style,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    title: Text(deck.name),
                    subtitle: Text(
                      l10n.translate(
                        'cardsCount',
                        params: {'count': deck.cards.length},
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(ctx);
                      await _handleMoveMultiple(
                        context,
                        viewModel,
                        deck.id,
                        deck.name,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
        ],
      ),
    );
  }

  static Future<void> _handleMoveMultiple(
    BuildContext context,
    DeckDetailViewModel viewModel,
    String destDeckId,
    String destDeckName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selectedIds = viewModel.selectedCardIds.toList();

    final result = await viewModel.moveMultipleCards(selectedIds, destDeckId);
    final conflicts = result['conflicts'] as List<Flashcard>;
    final cardsToMove = result['cardsToMove'] as List<Flashcard>;

    if (conflicts.isEmpty) {
      await viewModel.executeMoveMultiple(selectedIds, destDeckId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedIds.length} ${l10n.translate('cardsMoved')}',
            ),
            persist: false,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (context.mounted) {
        final proceed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.translate('duplicateCards')),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate(
                    'duplicateCardsMessage',
                    params: {
                      'count': conflicts.length,
                      'deckName': destDeckName,
                    },
                  ),
                ),
                const SizedBox(height: 16),
                if (conflicts.length <= 5)
                  ...conflicts.map(
                    (card) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        '• ${card.front}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                if (conflicts.length > 5)
                  Text(
                    '• ${conflicts.take(5).map((c) => c.front).join('\n• ')}\n...',
                    style: const TextStyle(fontSize: 12),
                  ),
                const SizedBox(height: 16),
                if (cardsToMove.isNotEmpty)
                  Text(
                    l10n.translate(
                      'cardsWillBeMoved',
                      params: {'count': cardsToMove.length},
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.translate('cancel')),
              ),
              if (cardsToMove.isNotEmpty)
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.translate('moveAnyway')),
                ),
            ],
          ),
        );

        if (proceed == true && cardsToMove.isNotEmpty) {
          await viewModel.executeMoveMultiple(
            cardsToMove.map((c) => c.id).toList(),
            destDeckId,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${cardsToMove.length} ${l10n.translate('cardsMoved')}',
                ),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    }
  }
}
