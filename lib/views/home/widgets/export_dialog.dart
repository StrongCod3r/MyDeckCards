import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../l10n/app_localizations.dart';

void showExportDialog(BuildContext context, HomeViewModel viewModel) {
  final l10n = AppLocalizations.of(context)!;
  final decks = viewModel.decks;

  if (decks.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.translate('exportCancelled')),
        persist: false,
        duration: const Duration(seconds: 3),
      ),
    );
    return;
  }

  final totalCards = decks.fold<int>(
    0,
    (sum, deck) => sum + deck.cards.length,
  );

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.translate('exportTitle')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('exportMessage')),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.folder_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.translate('cardsCount', params: {'count': decks.length}),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.style_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                l10n.translate('cardsCount', params: {'count': totalCards}),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.translate('selectFolder'),
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.translate('cancel')),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            _exportDecks(context, viewModel);
          },
          child: Text(l10n.translate('export')),
        ),
      ],
    ),
  );
}

Future<void> _exportDecks(
  BuildContext context,
  HomeViewModel viewModel,
) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final directoryPath = await FilePicker.platform.getDirectoryPath(
      dialogTitle: l10n.translate('selectFolder'),
    );

    if (directoryPath == null) {
      return;
    }

    if (!context.mounted) return;

    final jsonData = await viewModel.exportDecks();
    final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);

    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('$directoryPath/flashcards_export_$timestamp.json');
    await file.writeAsString(jsonString);

    if (context.mounted) {
      final decks = viewModel.decks;
      final totalCards = decks.fold<int>(
        0,
        (sum, deck) => sum + deck.cards.length,
      );

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(l10n.translate('exportSuccess')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate(
                  'exportSuccessMessage',
                  params: {
                    'deckCount': decks.length,
                    'cardCount': totalCards,
                  },
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.folder, size: 20, color: Colors.grey[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        file.path,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                          fontFamily: 'monospace',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.translate('ok')),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(l10n.translate('exportError')),
            ],
          ),
          content: Text('${l10n.translate('exportError')}:\n\n$e'),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.translate('ok')),
            ),
          ],
        ),
      );
    }
  }
}
