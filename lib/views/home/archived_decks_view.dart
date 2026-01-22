import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/settings_provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../l10n/app_localizations.dart';
import '../deck_detail/deck_detail_view.dart';
import 'widgets/deck_grid_item.dart';
import 'widgets/deck_list_item.dart';
import 'widgets/rename_deck_dialog.dart';
import 'widgets/icon_picker_dialog.dart';

class ArchivedDecksView extends StatelessWidget {
  const ArchivedDecksView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (context) {
        final viewModel = HomeViewModel(
          Provider.of<DeckProvider>(context, listen: false),
        );
        // Inicializar con el orden guardado
        viewModel.setSortOrder(
          Provider.of<SettingsProvider>(context, listen: false).decksSortOrder,
        );
        return viewModel;
      },
      child: Consumer<HomeViewModel>(
        builder: (context, viewModel, _) {
          final archivedDecks = viewModel.archivedDecks;
          final settingsProvider = Provider.of<SettingsProvider>(context);

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.translate('archivedDecks')),
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
              actions: [
                PopupMenuButton<SortOrder>(
                  icon: const Icon(Icons.sort),
                  tooltip: l10n.translate('sortBy'),
                  onSelected: (order) {
                    settingsProvider.setDecksSortOrder(order);
                    viewModel.setSortOrder(order);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: SortOrder.nameAsc,
                      child: Row(
                        children: [
                          Icon(
                            settingsProvider.decksSortOrder == SortOrder.nameAsc
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
                            settingsProvider.decksSortOrder == SortOrder.nameDesc
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
                            settingsProvider.decksSortOrder == SortOrder.dateCreated
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
                IconButton(
                  icon: Icon(
                    settingsProvider.viewMode == ViewMode.grid
                        ? Icons.view_list
                        : Icons.grid_view,
                  ),
                  onPressed: () {
                    settingsProvider.setViewMode(
                      settingsProvider.viewMode == ViewMode.grid
                          ? ViewMode.list
                          : ViewMode.grid,
                    );
                  },
                  tooltip: settingsProvider.viewMode == ViewMode.grid
                      ? 'Vista de lista'
                      : 'Vista de cuadrícula',
                ),
              ],
            ),
            body: archivedDecks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.archive_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.translate('noArchivedDecks'),
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Colors.grey[600],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : settingsProvider.viewMode == ViewMode.grid
                    ? _buildGridView(context, viewModel, archivedDecks, l10n)
                    : _buildListView(context, viewModel, archivedDecks, l10n),
          );
        },
      ),
    );
  }

  Widget _buildGridView(
    BuildContext context,
    HomeViewModel viewModel,
    List archivedDecks,
    AppLocalizations l10n,
  ) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.0,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: archivedDecks.length,
      itemBuilder: (context, index) {
        final deck = archivedDecks[index];
        return DeckGridItem(
          deck: deck,
          isArchived: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeckDetailView(deckId: deck.id),
              ),
            );
          },
          onRename: () => showRenameDeckDialog(
            context,
            viewModel,
            deck.id,
            deck.name,
          ),
          onChangeIcon: () => showIconPickerDialog(
            context,
            viewModel,
            deck.id,
            deck.icon,
          ),
          onUnarchive: () async {
            await viewModel.unarchiveDeck(deck.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.translate('unarchived')),
                  persist: false,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: l10n.translate('undo'),
                    onPressed: () => viewModel.archiveDeck(deck.id),
                  ),
                ),
              );
            }
          },
          onDelete: () => _handleDeleteDeck(context, viewModel, deck),
        );
      },
    );
  }

  Widget _buildListView(
    BuildContext context,
    HomeViewModel viewModel,
    List archivedDecks,
    AppLocalizations l10n,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: archivedDecks.length,
      itemBuilder: (context, index) {
        final deck = archivedDecks[index];
        return DeckListItem(
          deck: deck,
          isArchived: true,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeckDetailView(deckId: deck.id),
              ),
            );
          },
          onRename: () => showRenameDeckDialog(
            context,
            viewModel,
            deck.id,
            deck.name,
          ),
          onChangeIcon: () => showIconPickerDialog(
            context,
            viewModel,
            deck.id,
            deck.icon,
          ),
          onUnarchive: () async {
            await viewModel.unarchiveDeck(deck.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.translate('unarchived')),
                  persist: false,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: l10n.translate('undo'),
                    onPressed: () => viewModel.archiveDeck(deck.id),
                  ),
                ),
              );
            }
          },
          onDelete: () => _handleDeleteDeck(context, viewModel, deck),
        );
      },
    );
  }

  void _handleDeleteDeck(BuildContext context, HomeViewModel viewModel, deck) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('confirmDeleteDeck')),
        content: Text(
          l10n.translate('confirmDeleteDeckMessage', params: {'deckName': deck.name}),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () {
              viewModel.deleteDeck(deck.id);
              Navigator.pop(ctx);
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
