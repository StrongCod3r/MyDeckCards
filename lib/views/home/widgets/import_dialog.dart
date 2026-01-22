import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../l10n/app_localizations.dart';

void showImportDialog(BuildContext context, HomeViewModel viewModel) {
  final l10n = AppLocalizations.of(context)!;
  final colorScheme = Theme.of(context).colorScheme;
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.translate('importTitle')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.translate('importMessage')),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outline),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.translate('importMessage'),
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
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
            _importDecks(context, viewModel);
          },
          child: Text(l10n.translate('import')),
        ),
      ],
    ),
  );
}

Future<void> _importDecks(
  BuildContext context,
  HomeViewModel viewModel,
) async {
  final l10n = AppLocalizations.of(context)!;
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );

    if (result == null || result.files.isEmpty) return;

    final file = File(result.files.single.path!);
    final jsonString = await file.readAsString();
    final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

    if (!jsonData.containsKey('decks')) {
      throw Exception(l10n.translate('invalidJson'));
    }

    final decks = jsonData['decks'] as List;

    if (context.mounted) {
      final shouldImport = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.translate('confirmDeleteDeck')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('importMessage')),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.folder_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.translate(
                      'cardsCount',
                      params: {'count': decks.length},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.style_outlined, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    l10n.translate(
                      'cardsCount',
                      params: {
                        'count': decks.fold<int>(
                          0,
                          (sum, deck) => sum + (deck['cards'] as List).length,
                        ),
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.translate('cancel')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.translate('import')),
            ),
          ],
        ),
      );

      if (shouldImport != true) return;
    }

    if (!context.mounted) return;

    final importResult = await viewModel.importDecks(jsonData);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(l10n.translate('importSuccess')),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.translate(
                  'importSuccessMessage',
                  params: {
                    'deckCount': importResult['deckCount'],
                    'cardCount': importResult['cardCount'],
                  },
                ),
              ),
              if (importResult['renamedCount'] > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.orange[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.translate(
                            'importRenamed',
                            params: {'count': importResult['renamedCount']},
                          ),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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
              Text(l10n.translate('importError')),
            ],
          ),
          content: Text('${l10n.translate('importError')}:\n\n$e'),
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
