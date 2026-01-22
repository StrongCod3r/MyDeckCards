import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../services/predefined_decks_service.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../providers/deck_provider.dart';

class PredefinedDecksDialog extends StatefulWidget {
  const PredefinedDecksDialog({super.key});

  @override
  State<PredefinedDecksDialog> createState() => _PredefinedDecksDialogState();
}

class _PredefinedDecksDialogState extends State<PredefinedDecksDialog> {
  final PredefinedDecksService _service = PredefinedDecksService();
  final Set<String> _selectedDeckIds = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final allDecks = _service.getAvailableDecks();
    final englishDecks = allDecks.where((d) => d.language == 'english').toList();
    final spanishDecks = allDecks.where((d) => d.language == 'spanish').toList();

    return AlertDialog(
      title: Text(l10n.translate('selectDecksToLoad')),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(l10n.translate('loadingDecks')),
                  ],
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Selection buttons
                  Row(
                    children: [
                      TextButton(
                        onPressed: _selectAll,
                        child: Text(l10n.translate('selectAllDecks')),
                      ),
                      TextButton(
                        onPressed: _deselectAll,
                        child: Text(l10n.translate('deselectAllDecks')),
                      ),
                    ],
                  ),
                  const Divider(),

                  // Scrollable list with ListView.builder for better performance
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: englishDecks.length + spanishDecks.length + 2, // +2 for headers
                      itemBuilder: (context, index) {
                        // English section header
                        if (index == 0) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              l10n.translate('englishDecks'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          );
                        }

                        // English decks
                        if (index <= englishDecks.length) {
                          return _buildDeckCheckbox(englishDecks[index - 1]);
                        }

                        // Spanish section header
                        if (index == englishDecks.length + 1) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                            child: Text(
                              l10n.translate('spanishDecks'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          );
                        }

                        // Spanish decks
                        final spanishIndex = index - englishDecks.length - 2;
                        return _buildDeckCheckbox(spanishDecks[spanishIndex]);
                      },
                    ),
                  ),
                ],
              ),
      ),
      actions: _isLoading
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.translate('cancel')),
              ),
              FilledButton(
                onPressed: _selectedDeckIds.isEmpty ? null : _loadSelectedDecks,
                child: Text(l10n.translate('loadSelected')),
              ),
            ],
    );
  }

  Widget _buildDeckCheckbox(PredefinedDeckInfo deck) {
    final isSelected = _selectedDeckIds.contains(deck.id);
    return CheckboxListTile(
      value: isSelected,
      onChanged: (value) {
        setState(() {
          if (value == true) {
            _selectedDeckIds.add(deck.id);
          } else {
            _selectedDeckIds.remove(deck.id);
          }
        });
      },
      title: Row(
        children: [
          Text(deck.icon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 8),
          Expanded(child: Text(deck.name)),
        ],
      ),
      subtitle: Text('CEFR ${deck.level}'),
      dense: true,
    );
  }

  void _selectAll() {
    setState(() {
      _selectedDeckIds.addAll(_service.getAvailableDecks().map((d) => d.id));
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedDeckIds.clear();
    });
  }

  Future<void> _loadSelectedDecks() async {
    if (_selectedDeckIds.isEmpty) {
      _showMessage(
          AppLocalizations.of(context)!.translate('noDecksSelected'));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create HomeViewModel instance with DeckProvider
      final deckProvider = Provider.of<DeckProvider>(context, listen: false);
      final homeViewModel = HomeViewModel(deckProvider);

      int totalDecks = 0;
      int totalCards = 0;

      // Load each selected deck
      for (final deckId in _selectedDeckIds) {
        final jsonData = await _service.loadDeckById(deckId);
        final result = await homeViewModel.importDecks(jsonData);

        totalDecks += result['deckCount'] as int;
        totalCards += result['cardCount'] as int;
        // Note: renamed count is handled automatically by import logic
      }

      if (!mounted) return;

      // Close dialog
      Navigator.of(context).pop();

      // Show success message
      final l10n = AppLocalizations.of(context)!;
      _showSuccessDialog(
        l10n.translate('decksLoadedSuccess', params: {'count': totalDecks}),
        l10n.translate('cardsCount', params: {'count': totalCards}),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showMessage('Error loading decks: $e');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        persist: false,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessDialog(String title, String subtitle) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(subtitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(AppLocalizations.of(context)!.translate('ok')),
          ),
        ],
      ),
    );
  }
}
