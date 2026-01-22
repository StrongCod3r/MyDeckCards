import 'package:flutter/material.dart';
import '../../../models/flashcard.dart';
import '../../../viewmodels/deck_detail_viewmodel.dart';
import '../../../l10n/app_localizations.dart';
import 'add_edit_card_dialog.dart';
import 'move_card_dialog.dart';
import 'copy_card_dialog.dart';

class CardListItem extends StatelessWidget {
  final Flashcard card;
  final DeckDetailViewModel viewModel;

  const CardListItem({super.key, required this.card, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isSelected = viewModel.selectedCardIds.contains(card.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        onTap: () {
          if (viewModel.isSelectionMode) {
            viewModel.toggleCardSelection(card.id);
          } else {
            AddEditCardDialog.showEdit(context, viewModel, card);
          }
        },
        onLongPress: () {
          if (!viewModel.isSelectionMode) {
            viewModel.toggleSelectionMode();
            viewModel.toggleCardSelection(card.id);
          }
        },
        leading: viewModel.isSelectionMode
            ? Checkbox(
                value: isSelected,
                onChanged: (value) => viewModel.toggleCardSelection(card.id),
              )
            : null,
        title: Text(
          card.front,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(card.back, maxLines: 2, overflow: TextOverflow.ellipsis),
        trailing: viewModel.isSelectionMode
            ? null
            : _buildPopupMenu(context, l10n),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, AppLocalizations l10n) {
    return PopupMenuButton(
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              const Icon(Icons.edit),
              const SizedBox(width: 8),
              Text(l10n.translate('editCard')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'move',
          child: Row(
            children: [
              const Icon(Icons.drive_file_move),
              const SizedBox(width: 8),
              Text(l10n.translate('moveCard')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'copy',
          child: Row(
            children: [
              const Icon(Icons.content_copy),
              const SizedBox(width: 8),
              Text(l10n.translate('copyCard')),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'delete',
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
      onSelected: (value) {
        if (value == 'edit') {
          AddEditCardDialog.showEdit(context, viewModel, card);
        } else if (value == 'move') {
          MoveCardDialog.showSingle(context, viewModel, card);
        } else if (value == 'copy') {
          CopyCardDialog.showSingle(context, viewModel, card);
        } else if (value == 'delete') {
          _confirmDeleteCard(context);
        }
      },
    );
  }

  void _confirmDeleteCard(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('confirmDeleteCard')),
        content: Text(l10n.translate('confirmDeleteCardMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () {
              viewModel.deleteCard(card.id);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text(l10n.translate('delete')),
          ),
        ],
      ),
    );
  }
}
