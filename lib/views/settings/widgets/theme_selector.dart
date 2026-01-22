import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return ListTile(
          leading: const Icon(Icons.palette),
          title: Text(AppLocalizations.of(context)!.translate('theme')),
          subtitle: Text(_getThemeModeText(context, settingsProvider.themeMode)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showThemeDialog(context, settingsProvider),
        );
      },
    );
  }

  String _getThemeModeText(BuildContext context, ThemeMode mode) {
    final l10n = AppLocalizations.of(context)!;
    switch (mode) {
      case ThemeMode.light:
        return l10n.translate('themeLight');
      case ThemeMode.dark:
        return l10n.translate('themeDark');
      case ThemeMode.system:
        return l10n.translate('themeSystem');
    }
  }

  void _showThemeDialog(BuildContext context, SettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;
    ThemeMode selectedValue = settingsProvider.themeMode;

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.translate('selectTheme')),
        children: [
          SimpleDialogOption(
            onPressed: () {
              settingsProvider.setThemeMode(ThemeMode.light);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                if (selectedValue == ThemeMode.light)
                  const Icon(Icons.check, color: Colors.blue)
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 12),
                Text(l10n.translate('themeLight')),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              settingsProvider.setThemeMode(ThemeMode.dark);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                if (selectedValue == ThemeMode.dark)
                  const Icon(Icons.check, color: Colors.blue)
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 12),
                Text(l10n.translate('themeDark')),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              settingsProvider.setThemeMode(ThemeMode.system);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                if (selectedValue == ThemeMode.system)
                  const Icon(Icons.check, color: Colors.blue)
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 12),
                Text(l10n.translate('themeSystem')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
