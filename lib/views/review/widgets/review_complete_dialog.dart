import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';

class ReviewCompleteDialog extends StatelessWidget {
  final int correctCount;
  final int incorrectCount;
  final VoidCallback onFinish;
  final VoidCallback onReviewAgain;

  const ReviewCompleteDialog({
    super.key,
    required this.correctCount,
    required this.incorrectCount,
    required this.onFinish,
    required this.onReviewAgain,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.translate('reviewCompleted')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 64, color: Colors.green[400]),
          const SizedBox(height: 16),
          Text(
            l10n.translate('correct', params: {'count': correctCount}),
            style: const TextStyle(fontSize: 18),
          ),
          Text(
            l10n.translate('incorrect', params: {'count': incorrectCount}),
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: onFinish, child: Text(l10n.translate('finish'))),
        FilledButton(
          onPressed: onReviewAgain,
          child: Text(l10n.translate('reviewAgain')),
        ),
      ],
    );
  }
}
