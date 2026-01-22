import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'widgets/theme_selector.dart';
import 'widgets/language_selector.dart';
import 'widgets/screen_wakelock_toggle.dart';
import 'widgets/predefined_decks_selector.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('settings')),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ThemeSelector(),
          const LanguageSelector(),
          const Divider(),
          const ScreenWakeLockToggle(),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.translate('contentLibrary'),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          const PredefinedDecksSelector(),
        ],
      ),
    );
  }
}
