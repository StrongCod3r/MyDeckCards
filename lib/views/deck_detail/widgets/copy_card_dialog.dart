import 'package:flutter/material.dart';
import '../../../models/flashcard.dart';
import '../../../viewmodels/deck_detail_viewmodel.dart';
import '../../../l10n/app_localizations.dart';

class CopyCardDialog {
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
        title: Text(l10n.translate('copyCardTitle')),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('selectDestinationDeck')),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: otherDecks.length,
                  itemBuilder: (context, index) {
                    final deck = otherDecks[index];
                    return ListTile(
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
                      onTap: () {
                        viewModel.copyCard(card.id, deck.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.translate('cardCopied')),
                            persist: false,
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
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
        title: Text(l10n.translate('copyCardTitle')),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('selectDestinationDeck')),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: otherDecks.length,
                  itemBuilder: (context, index) {
                    final deck = otherDecks[index];
                    return ListTile(
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
                        await _handleCopyMultiple(
                          context,
                          viewModel,
                          deck.id,
                          deck.name,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
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

  static Future<void> _handleCopyMultiple(
    BuildContext context,
    DeckDetailViewModel viewModel,
    String destDeckId,
    String destDeckName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final selectedIds = viewModel.selectedCardIds.toList();

    final result = await viewModel.copyMultipleCards(selectedIds, destDeckId);
    final conflicts = result['conflicts'] as List<Flashcard>;
    final cardsToCopy = result['cardsToCopy'] as List<Flashcard>;

    if (conflicts.isEmpty) {
      await viewModel.executeCopyMultiple(selectedIds, destDeckId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedIds.length} ${l10n.translate('cardsCopied')}',
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
                if (cardsToCopy.isNotEmpty)
                  Text(
                    l10n.translate(
                      'cardsWillBeCopied',
                      params: {'count': cardsToCopy.length},
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.translate('cancel')),
              ),
              if (cardsToCopy.isNotEmpty)
                FilledButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(l10n.translate('copyAnyway')),
                ),
            ],
          ),
        );

        if (proceed == true && cardsToCopy.isNotEmpty) {
          await viewModel.executeCopyMultiple(
            cardsToCopy.map((c) => c.id).toList(),
            destDeckId,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${cardsToCopy.length} ${l10n.translate('cardsCopied')}',
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
