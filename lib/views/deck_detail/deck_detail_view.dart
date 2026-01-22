import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/settings_provider.dart';
import '../../viewmodels/deck_detail_viewmodel.dart';
import '../../views/review/review_view.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/card_list_item.dart';
import 'widgets/add_edit_card_dialog.dart';
import 'widgets/move_card_dialog.dart';
import 'widgets/copy_card_dialog.dart';
import 'widgets/selection_app_bar.dart';

class DeckDetailView extends StatelessWidget {
  final String deckId;

  const DeckDetailView({super.key, required this.deckId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = DeckDetailViewModel(
          Provider.of<DeckProvider>(context, listen: false),
          deckId,
        );
        // Inicializar con el orden guardado
        viewModel.setSortOrder(
          Provider.of<SettingsProvider>(context, listen: false).cardsSortOrder,
        );
        return viewModel;
      },
      child: Consumer<DeckDetailViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            appBar: _buildAppBar(context, viewModel, l10n),
            body: _buildBody(context, viewModel, l10n),
            floatingActionButton: _buildFAB(context, viewModel),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    DeckDetailViewModel viewModel,
    AppLocalizations l10n,
  ) {
    if (viewModel.isSelectionMode) {
      return SelectionAppBar(
        viewModel: viewModel,
        l10n: l10n,
        onMovePressed: () => MoveCardDialog.showMultiple(context, viewModel),
        onCopyPressed: () => CopyCardDialog.showMultiple(context, viewModel),
        onDeletePressed: () => _showDeleteMultipleDialog(context, viewModel, l10n),
      );
    }

    final settingsProvider = Provider.of<SettingsProvider>(context);

    return AppBar(
      title: Text(viewModel.deck?.name ?? l10n.translate('appTitle')),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      actions: [
        if (viewModel.deck != null && viewModel.cards.isNotEmpty)
          PopupMenuButton<SortOrder>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.translate('sortBy'),
            onSelected: (order) {
              settingsProvider.setCardsSortOrder(order);
              viewModel.setSortOrder(order);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: SortOrder.nameAsc,
                child: Row(
                  children: [
                    Icon(
                      settingsProvider.cardsSortOrder == SortOrder.nameAsc
                          ? Icons.check
                          : Icons.sort_by_alpha,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.translate('sortNameAsc')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOrder.nameDesc,
                child: Row(
                  children: [
                    Icon(
                      settingsProvider.cardsSortOrder == SortOrder.nameDesc
                          ? Icons.check
                          : Icons.sort_by_alpha,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.translate('sortNameDesc')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: SortOrder.dateCreated,
                child: Row(
                  children: [
                    Icon(
                      settingsProvider.cardsSortOrder == SortOrder.dateCreated
                          ? Icons.check
                          : Icons.access_time,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.translate('sortDateCreated')),
                  ],
                ),
              ),
            ],
          ),
        if (viewModel.deck != null && viewModel.cards.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.checklist),
            tooltip: l10n.translate('selectMultiple'),
            onPressed: () => viewModel.toggleSelectionMode(),
          ),
        if (viewModel.deck != null && viewModel.cards.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.play_arrow),
            tooltip: l10n.translate('review'),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewView(deckId: deckId),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    DeckDetailViewModel viewModel,
    AppLocalizations l10n,
  ) {
    if (viewModel.deck == null) {
      return Center(child: Text(l10n.translate('appTitle')));
    }

    if (viewModel.cards.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style_outlined, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.translate('emptyDeck'),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: viewModel.cards.length,
      itemBuilder: (context, index) {
        final card = viewModel.cards[index];
        return CardListItem(card: card, viewModel: viewModel);
      },
    );
  }

  Widget? _buildFAB(BuildContext context, DeckDetailViewModel viewModel) {
    if (viewModel.isSelectionMode) return null;

    return FloatingActionButton(
      onPressed: () => AddEditCardDialog.showAdd(context, viewModel),
      child: const Icon(Icons.add),
    );
  }

  void _showDeleteMultipleDialog(
    BuildContext context,
    DeckDetailViewModel viewModel,
    AppLocalizations l10n,
  ) {
    final count = viewModel.selectedCount;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('confirmDeleteMultiple').replaceAll('{count}', count.toString())),
        content: Text(l10n.translate('confirmDeleteMultipleMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              final selectedIds = List<String>.from(viewModel.selectedCardIds);
              await viewModel.deleteMultipleCards(selectedIds);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$count ${l10n.translate('cardsDeleted')}'),
                    persist: false,
                    duration: const Duration(seconds: 3),
                  ),
                );
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: Text(l10n.translate('delete')),
          ),
        ],
      ),
    );
  }
}
