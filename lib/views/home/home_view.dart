import 'package:flutter/material.dart';
import 'package:mydeckcards/views/home/about_view.dart';
import 'package:provider/provider.dart';
import '../../providers/deck_provider.dart';
import '../../providers/settings_provider.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../l10n/app_localizations.dart';
import '../deck_detail/deck_detail_view.dart';
import '../settings/settings_view.dart';
import 'widgets/deck_grid_item.dart';
import 'widgets/deck_list_item.dart';
import 'widgets/create_deck_dialog.dart';
import 'widgets/rename_deck_dialog.dart';
import 'widgets/icon_picker_dialog.dart';
import 'archived_decks_view.dart';
import 'widgets/export_dialog.dart';
import 'widgets/import_dialog.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
          final activeDecks = viewModel.activeDecks;
          final settingsProvider = Provider.of<SettingsProvider>(context);

          return Scaffold(
            appBar: AppBar(
              title: Text(l10n.translate('myDecks')),
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
                            settingsProvider.decksSortOrder ==
                                    SortOrder.nameDesc
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
                            settingsProvider.decksSortOrder ==
                                    SortOrder.dateCreated
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
                if (viewModel.archivedDecks.isNotEmpty)
                  Stack(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.archive),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ArchivedDecksView(),
                            ),
                          );
                        },
                      ),
                      Positioned(
                        right: 8,
                        top: 8,
                        child: IgnorePointer(
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${viewModel.archivedDecks.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            drawer: _buildDrawer(context, viewModel, l10n),
            body: activeDecks.isEmpty
                ? Center(
                    child: Text(
                      l10n.translate('emptyDecks'),
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  )
                : settingsProvider.viewMode == ViewMode.grid
                ? _buildGridView(context, viewModel, activeDecks, l10n)
                : _buildListView(context, viewModel, activeDecks, l10n),
            floatingActionButton: FloatingActionButton(
              onPressed: () => showCreateDeckDialog(context, viewModel),
              child: const Icon(Icons.add),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGridView(
    BuildContext context,
    HomeViewModel viewModel,
    List activeDecks,
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
      itemCount: activeDecks.length,
      itemBuilder: (context, index) {
        final deck = activeDecks[index];
        return DeckGridItem(
          deck: deck,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeckDetailView(deckId: deck.id),
              ),
            );
          },
          onRename: () =>
              showRenameDeckDialog(context, viewModel, deck.id, deck.name),
          onChangeIcon: () =>
              showIconPickerDialog(context, viewModel, deck.id, deck.icon),
          onArchive: () async {
            await viewModel.archiveDeck(deck.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.translate('archived')),
                  persist: false,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: l10n.translate('undo'),
                    onPressed: () => viewModel.unarchiveDeck(deck.id),
                  ),
                ),
              );
            }
          },
          onDelete: () => _handleDeleteDeck(context, viewModel, deck.id),
        );
      },
    );
  }

  Widget _buildListView(
    BuildContext context,
    HomeViewModel viewModel,
    List activeDecks,
    AppLocalizations l10n,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: activeDecks.length,
      itemBuilder: (context, index) {
        final deck = activeDecks[index];
        return DeckListItem(
          deck: deck,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DeckDetailView(deckId: deck.id),
              ),
            );
          },
          onRename: () =>
              showRenameDeckDialog(context, viewModel, deck.id, deck.name),
          onChangeIcon: () =>
              showIconPickerDialog(context, viewModel, deck.id, deck.icon),
          onArchive: () async {
            await viewModel.archiveDeck(deck.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.translate('archived')),
                  persist: false,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: l10n.translate('undo'),
                    onPressed: () => viewModel.unarchiveDeck(deck.id),
                  ),
                ),
              );
            }
          },
          onDelete: () => _handleDeleteDeck(context, viewModel, deck.id),
        );
      },
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    HomeViewModel viewModel,
    AppLocalizations l10n,
  ) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Image.asset(
                        'assets/logo.png',
                        width: 64,
                        height: 64,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.translate('appTitle'),
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: Text(l10n.translate('exportDecks')),
                  onTap: () {
                    Navigator.pop(context);
                    showExportDialog(context, viewModel);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: Text(l10n.translate('importDecks')),
                  onTap: () {
                    Navigator.pop(context);
                    showImportDialog(context, viewModel);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: Text(l10n.translate('settings')),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsView()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.translate('about')),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AboutView()),
              );
            },
          ),
        ],
      ),
    );
  }

  void _handleDeleteDeck(
    BuildContext context,
    HomeViewModel viewModel,
    String deckId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.translate('confirmDeleteDeck')),
        content: Text(l10n.translate('confirmDeleteDeckMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () {
              viewModel.deleteDeck(deckId);
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
