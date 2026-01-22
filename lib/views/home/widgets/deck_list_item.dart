import 'package:flutter/material.dart';
import '../../../models/deck.dart';
import '../../../l10n/app_localizations.dart';

class DeckListItem extends StatelessWidget {
  final Deck deck;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onChangeIcon;
  final VoidCallback? onArchive;
  final VoidCallback? onUnarchive;
  final VoidCallback onDelete;
  final bool isArchived;

  const DeckListItem({
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: deck.icon != null
              ? Text(deck.icon!, style: const TextStyle(fontSize: 24))
              : Icon(
                  Icons.style,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
        ),
        title: Text(
          deck.name,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Text(
          l10n.translate('cardsCount', params: {'count': deck.cards.length}),
        ),
        trailing: PopupMenuButton(
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
    );
  }
}
