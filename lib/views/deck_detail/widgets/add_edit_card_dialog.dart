import 'package:flutter/material.dart';
import '../../../models/flashcard.dart';
import '../../../viewmodels/deck_detail_viewmodel.dart';
import '../../../l10n/app_localizations.dart';

class AddEditCardDialog extends StatefulWidget {
  final DeckDetailViewModel viewModel;
  final Flashcard? card;
  final bool isAdd;

  const AddEditCardDialog({
    super.key,
    required this.viewModel,
    this.card,
    required this.isAdd,
  });

  static void showAdd(BuildContext context, DeckDetailViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AddEditCardDialog(viewModel: viewModel, isAdd: true),
    );
  }

  static void showEdit(
    BuildContext context,
    DeckDetailViewModel viewModel,
    Flashcard card,
  ) {
    showDialog(
      context: context,
      builder: (ctx) =>
          AddEditCardDialog(viewModel: viewModel, card: card, isAdd: false),
    );
  }

  @override
  State<AddEditCardDialog> createState() => _AddEditCardDialogState();
}

class _AddEditCardDialogState extends State<AddEditCardDialog> {
  late TextEditingController _frontController;
  late TextEditingController _backController;
  String? _frontError;
  String? _backError;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(text: widget.card?.front ?? '');
    _backController = TextEditingController(text: widget.card?.back ?? '');
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(
        widget.isAdd ? l10n.translate('addCard') : l10n.translate('editCard'),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _frontController,
            decoration: InputDecoration(
              labelText: l10n.translate('front'),
              border: const OutlineInputBorder(),
              errorText: _frontError,
            ),
            textCapitalization: TextCapitalization.none,
            enableInteractiveSelection: true,
            autofocus: true,
            onChanged: (value) {
              setState(() {
                _frontError = null;
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _backController,
            decoration: InputDecoration(
              labelText: l10n.translate('back'),
              border: const OutlineInputBorder(),
              errorText: _backError,
            ),
            autofocus: false,
            textCapitalization: TextCapitalization.none,
            enableInteractiveSelection: true,
            keyboardType: TextInputType.text,
            maxLines: 3,
            onChanged: (value) {
              setState(() {
                _backError = null;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.translate('cancel')),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: Text(
            widget.isAdd ? l10n.translate('add') : l10n.translate('save'),
          ),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    final l10n = AppLocalizations.of(context)!;
    final front = _frontController.text.trim();
    final back = _backController.text.trim();

    bool success;
    if (widget.isAdd) {
      success = await widget.viewModel.addCard(front, back);
    } else {
      success = await widget.viewModel.updateCard(widget.card!.id, front, back);
    }

    if (!success && widget.viewModel.errorMessage != null) {
      setState(() {
        final error = widget.viewModel.errorMessage!;
        if (error == 'frontRequired' || error == 'cardExists') {
          _frontError = l10n.translate(error);
        } else if (error == 'backRequired') {
          _backError = l10n.translate(error);
        }
      });
      return;
    }

    if (mounted) {
      Navigator.pop(context);
      // If adding, show the dialog again for convenience
      if (widget.isAdd) {
        AddEditCardDialog.showAdd(context, widget.viewModel);
      }
    }
  }
}
