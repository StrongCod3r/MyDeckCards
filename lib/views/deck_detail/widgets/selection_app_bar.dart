import 'package:flutter/material.dart';
import '../../../viewmodels/deck_detail_viewmodel.dart';
import '../../../l10n/app_localizations.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  final DeckDetailViewModel viewModel;
  final AppLocalizations l10n;
  final VoidCallback onMovePressed;
  final VoidCallback onCopyPressed;
  final VoidCallback onDeletePressed;

  const SelectionAppBar({
    super.key,
    required this.viewModel,
    required this.l10n,
    required this.onMovePressed,
    required this.onCopyPressed,
    required this.onDeletePressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text('${viewModel.selectedCount} ${l10n.translate('selected')}'),
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: () => viewModel.toggleSelectionMode(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: l10n.translate('selectAll'),
          onPressed: () => viewModel.selectAll(),
        ),
        IconButton(
          icon: const Icon(Icons.drive_file_move),
          tooltip: l10n.translate('moveCard'),
          onPressed: viewModel.selectedCount > 0 ? onMovePressed : null,
        ),
        IconButton(
          icon: const Icon(Icons.content_copy),
          tooltip: l10n.translate('copyCard'),
          onPressed: viewModel.selectedCount > 0 ? onCopyPressed : null,
        ),
        IconButton(
          icon: const Icon(Icons.delete),
          tooltip: l10n.translate('delete'),
          onPressed: viewModel.selectedCount > 0 ? onDeletePressed : null,
        ),
      ],
    );
  }
}
