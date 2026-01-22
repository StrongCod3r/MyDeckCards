import 'package:flutter/material.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../l10n/app_localizations.dart';

void showCreateDeckDialog(BuildContext context, HomeViewModel viewModel) {
  final l10n = AppLocalizations.of(context)!;
  final controller = TextEditingController();

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
        title: Text(l10n.translate('createDeck')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.translate('deckName'),
            border: const OutlineInputBorder(),
            errorText: viewModel.errorMessage != null
                ? l10n.translate(viewModel.errorMessage!)
                : null,
          ),
          textCapitalization: TextCapitalization.sentences,
          enableInteractiveSelection: true,
          autofocus: true,
          onChanged: (value) {
            setState(() {
              viewModel.clearError();
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () async {
              final name = controller.text.trim();
              final success = await viewModel.addDeck(name);
              if (success && context.mounted) {
                Navigator.pop(ctx);
              } else {
                setState(() {}); // Rebuild to show error
              }
            },
            child: Text(l10n.translate('create')),
          ),
        ],
      ),
    ),
  );
}
