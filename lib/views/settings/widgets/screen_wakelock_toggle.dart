import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../../providers/settings_provider.dart';

class ScreenWakeLockToggle extends StatelessWidget {
  const ScreenWakeLockToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, _) {
        final l10n = AppLocalizations.of(context)!;
        return SwitchListTile(
          secondary: const Icon(Icons.screen_lock_portrait),
          title: Text(l10n.translate('keepScreenOn')),
          subtitle: Text(l10n.translate('keepScreenOnDescription')),
          value: settingsProvider.keepScreenOn,
          onChanged: (value) {
            settingsProvider.setKeepScreenOn(value);
          },
        );
      },
    );
  }
}
