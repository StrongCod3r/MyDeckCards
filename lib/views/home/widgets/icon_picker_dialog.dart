import 'package:flutter/material.dart';
import '../../../viewmodels/home_viewmodel.dart';
import '../../../l10n/app_localizations.dart';
import 'emoji_categories.dart';

void showIconPickerDialog(
  BuildContext context,
  HomeViewModel viewModel,
  String deckId,
  String? currentIcon,
) {
  final l10n = AppLocalizations.of(context)!;

  showDialog(
    context: context,
    builder: (ctx) => DefaultTabController(
      length: emojiCategories.length,
      child: AlertDialog(
        title: Text(l10n.translate('selectIcon')),
        content: SizedBox(
          width: double.maxFinite,
          height: 450,
          child: Column(
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: emojiCategories.keys.map((icon) {
                  return Tab(
                    child: Text(icon, style: const TextStyle(fontSize: 24)),
                  );
                }).toList(),
              ),
              Expanded(
                child: TabBarView(
                  children: emojiCategories.entries.map((category) {
                    return GridView.builder(
                      padding: const EdgeInsets.only(top: 16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6,
                            childAspectRatio: 1,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: category.value.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0 &&
                            category.key == emojiCategories.keys.first) {
                          // Default Icon option only in first tab
                          final isSelected = currentIcon == null;
                          return InkWell(
                            onTap: () {
                              viewModel.updateDeckIcon(deckId, null);
                              Navigator.pop(ctx);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.block,
                                size: 32,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }

                        final adjustedIndex =
                            (index == 0 &&
                                category.key == emojiCategories.keys.first)
                            ? 0
                            : (category.key == emojiCategories.keys.first
                                  ? index - 1
                                  : index);

                        if (adjustedIndex >= category.value.length) {
                          return const SizedBox.shrink();
                        }

                        final emoji = category.value[adjustedIndex];
                        final isSelected = emoji == currentIcon;

                        return InkWell(
                          onTap: () {
                            viewModel.updateDeckIcon(deckId, emoji);
                            Navigator.pop(ctx);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey.shade300,
                                width: isSelected ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: const TextStyle(fontSize: 28),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.translate('cancel')),
          ),
        ],
      ),
    ),
  );
}
