import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ReviewExitDialog extends StatelessWidget {
  const ReviewExitDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.translate('exitReview')),
      content: Text(l10n.translate('exitReviewMessage')),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.translate('cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: Colors.red),
          child: Text(l10n.translate('exit')),
        ),
      ],
    );
  }
}
