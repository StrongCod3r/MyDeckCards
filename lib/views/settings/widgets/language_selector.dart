import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        return ListTile(
          leading: const Icon(Icons.language),
          title: Text(AppLocalizations.of(context)!.translate('language')),
          subtitle: Text(_getLanguageText(context, settingsProvider.locale)),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => _showLanguageDialog(context, settingsProvider),
        );
      },
    );
  }

  String _getLanguageText(BuildContext context, Locale? locale) {
    final l10n = AppLocalizations.of(context)!;
    if (locale == null) {
      return l10n.translate('languageSystem');
    }
    switch (locale.languageCode) {
      case 'en':
        return l10n.translate('languageEnglish');
      case 'es':
        return l10n.translate('languageSpanish');
      default:
        return l10n.translate('languageSystem');
    }
  }

  void _showLanguageDialog(BuildContext context, SettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;
    String selectedValue = settingsProvider.locale?.languageCode ?? 'system';

    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(l10n.translate('selectLanguage')),
        children: [
          SimpleDialogOption(
            onPressed: () {
              settingsProvider.setLocale(const Locale('en'));
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                if (selectedValue == 'en')
                  const Icon(Icons.check, color: Colors.blue)
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 12),
                Text(l10n.translate('languageEnglish')),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              settingsProvider.setLocale(const Locale('es'));
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                if (selectedValue == 'es')
                  const Icon(Icons.check, color: Colors.blue)
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 12),
                Text(l10n.translate('languageSpanish')),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              settingsProvider.setLocale(null);
              Navigator.pop(ctx);
            },
            child: Row(
              children: [
                if (selectedValue == 'system')
                  const Icon(Icons.check, color: Colors.blue)
                else
                  const SizedBox(width: 24),
                const SizedBox(width: 12),
                Text(l10n.translate('languageSystem')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
