import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/flashcard.dart';
import '../../../providers/deck_provider.dart';
import '../../../l10n/app_localizations.dart';

class CopyCardFromReviewDialog {
  static void show(
    BuildContext context,
    Flashcard card,
    String currentDeckId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final deckProvider = Provider.of<DeckProvider>(context, listen: false);

    // Get all decks except the current one
    final otherDecks = deckProvider.decks
        .where((deck) => deck.id != currentDeckId && !deck.archived)
        .toList();

    if (otherDecks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
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
              const SizedBox(height: 8),
              // Show the card being copied
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card.front,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card.back,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer
                              .withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Use Flexible with ListView.builder for better performance
              Flexible(
                child: otherDecks.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.builder(
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

                      // Check if card already exists in destination deck
                      final cardExists = deck.cards.any((c) => c.front == card.front);

                      if (cardExists) {
                        // Show confirmation dialog
                        final proceed = await showDialog<bool>(
                          context: context,
                          builder: (confirmCtx) => AlertDialog(
                            title: Text(l10n.translate('duplicateCards')),
                            content: Text(
                              l10n.translate(
                                'duplicateCardsMessage',
                                params: {
                                  'count': 1,
                                  'deckName': deck.name,
                                },
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(confirmCtx, false),
                                child: Text(l10n.translate('cancel')),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(confirmCtx, true),
                                child: Text(l10n.translate('copyAnyway')),
                              ),
                            ],
                          ),
                        );

                        if (proceed != true) return;
                      }

                      // Copy the card
                      await deckProvider.addCard(deck.id, card.front, card.back);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.translate('cardCopied')),
                            duration: const Duration(seconds: 3),
                            persist: false,
                            action: SnackBarAction(
                              label: l10n.translate('undo'),
                              onPressed: () {
                                // Find the copied card and remove it
                                final updatedDeck = deckProvider.decks
                                    .firstWhere((d) => d.id == deck.id);
                                final copiedCard = updatedDeck.cards
                                    .where((c) => c.front == card.front && c.back == card.back)
                                    .lastOrNull;
                                if (copiedCard != null) {
                                  deckProvider.deleteCard(deck.id, copiedCard.id);
                                }
                              },
                            ),
                          ),
                        );
                              }
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
}
