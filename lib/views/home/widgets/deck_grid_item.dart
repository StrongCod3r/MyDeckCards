import 'package:flutter/material.dart';
import '../../../models/deck.dart';
import '../../../l10n/app_localizations.dart';

class DeckGridItem extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onChangeIcon;
  final VoidCallback? onArchive;
  final VoidCallback? onUnarchive;
  final VoidCallback onDelete;
  final bool isArchived;

  const DeckGridItem({
    super.key,
    required this.deck,
    required this.onTap,
    required this.onRename,
    required this.onChangeIcon,
    this.onArchive,
    this.onUnarchive,
    required this.onDelete,
    this.isArchived = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (deck.icon != null)
                      Text(
                        deck.icon!,
                        style: const TextStyle(fontSize: 48),
                      )
                    else
                      Icon(
                        Icons.style,
                        size: 48,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    const SizedBox(height: 12),
                    Text(
                      deck.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.translate('cardsCount', params: {'count': deck.cards.length}),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    onTap: onRename,
                    child: Row(
                      children: [
                        const Icon(Icons.edit),
                        const SizedBox(width: 8),
                        Text(l10n.translate('renameDeck')),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    onTap: onChangeIcon,
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_emotions),
                        const SizedBox(width: 8),
                        Text(l10n.translate('changeIcon')),
                      ],
                    ),
                  ),
                  if (!isArchived && onArchive != null)
                    PopupMenuItem(
                      onTap: onArchive,
                      child: Row(
                        children: [
                          const Icon(Icons.archive),
                          const SizedBox(width: 8),
                          Text(l10n.translate('archive')),
                        ],
                      ),
                    ),
                  if (isArchived && onUnarchive != null)
                    PopupMenuItem(
                      onTap: onUnarchive,
                      child: Row(
                        children: [
                          const Icon(Icons.unarchive),
                          const SizedBox(width: 8),
                          Text(l10n.translate('unarchive')),
                        ],
                      ),
                    ),
                  PopupMenuItem(
                    onTap: onDelete,
                    child: Row(
                      children: [
                        const Icon(Icons.delete, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          l10n.translate('delete'),
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
