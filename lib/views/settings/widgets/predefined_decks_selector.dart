import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import 'predefined_decks_dialog.dart';

class PredefinedDecksSelector extends StatelessWidget {
  const PredefinedDecksSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListTile(
      leading: const Icon(Icons.library_books),
      title: Text(l10n.translate('loadPredefinedDecks')),
      subtitle: Text(l10n.translate('predefinedDecks')),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _showPredefinedDecksDialog(context),
    );
  }

  void _showPredefinedDecksDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const PredefinedDecksDialog(),
    );
  }
}
