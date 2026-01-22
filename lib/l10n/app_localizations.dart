import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'about': 'About',
      'aboutDescription': '{app} is an open-source flashcard app for learning and memorization. Created with ❤️ using Flutter.',
      // App general
      'appTitle': 'MyDeckCards',

      // Home screen
      'myDecks': 'My Decks',
      'createDeck': 'Create Deck',
      'deckName': 'Deck Name',
      'cancel': 'Cancel',
      'create': 'Create',
      'close': 'Close',
      'cardsCount': '{count} cards',
      'emptyDecks': 'No decks yet\nTap + to create one',
      'deckNameRequired': 'Please enter a deck name',
      'deckNameExists': 'A deck with this name already exists',
      'confirmDeleteDeck': 'Delete deck?',
      'confirmDeleteDeckMessage':
          'This will delete all cards in this deck. This action cannot be undone.',
      'delete': 'Delete',
      'renameDeck': 'Rename Deck',
      'newName': 'New Name',
      'rename': 'Rename',
      'changeIcon': 'Change Icon',
      'selectIcon': 'Select Icon',
      'noIcon': 'No Icon',
      'archive': 'Archive',
      'unarchive': 'Unarchive',
      'archived': 'Archived',
      'archivedDecks': 'Archived Decks',
      'noArchivedDecks': 'No archived decks',
      'unarchived': 'Unarchived',
      'undo': 'Undo',

      // Drawer menu
      'settings': 'Settings',
      'exportDecks': 'Export Decks',
      'importDecks': 'Import Decks',

      // Export/Import
      'exportTitle': 'Export Decks',
      'exportMessage': 'This will export all your decks to a JSON file.',
      'export': 'Export',
      'selectFolder': 'Select where to save the file',
      'exportSuccess': 'Export Successful',
      'exportSuccessMessage':
          'Exported {deckCount} decks with {cardCount} total cards to:',
      'exportError': 'Export Error',
      'exportCancelled': 'Export cancelled',
      'importTitle': 'Import Decks',
      'importMessage':
          'Select a JSON file to import decks.\n\nNote: If a deck with the same name exists, it will be renamed automatically.',
      'import': 'Import',
      'importSuccess': 'Import Successful',
      'importSuccessMessage':
          'Imported {deckCount} decks with {cardCount} total cards.',
      'importRenamed': '{count} decks were renamed to avoid conflicts.',
      'importError': 'Import Error',
      'importCancelled': 'Import cancelled',
      'invalidJson': 'Invalid JSON file',
      'ok': 'OK',

      // Deck detail screen
      'addCard': 'Add Card',
      'editCard': 'Edit Card',
      'front': 'Front (Word/Question)',
      'back': 'Back (Meaning/Answer)',
      'add': 'Add',
      'save': 'Save',
      'emptyDeck': 'No cards yet\nTap + to add one',
      'frontRequired': 'Please enter the front of the card',
      'backRequired': 'Please enter the back of the card',
      'cardExists': 'A card with this front already exists',
      'confirmDeleteCard': 'Delete card?',
      'confirmDeleteCardMessage': 'This action cannot be undone.',
      'addAnother': 'Add Another',
      'moveCard': 'Move to Another Deck',
      'moveCardTitle': 'Move Card',
      'selectDestinationDeck': 'Select destination deck:',
      'move': 'Move',
      'cardMoved': 'Card moved successfully',
      'copyCard': 'Copy to Another Deck',
      'copyCardTitle': 'Copy Card',
      'cardCopied': 'Card copied successfully',
      'selectMultiple': 'Select Multiple',
      'selected': 'selected',
      'selectAll': 'Select All',
      'cardsMoved': 'cards moved',
      'cardsCopied': 'cards copied',
      'cardsDeleted': 'cards deleted',
      'confirmDeleteMultiple': 'Delete {count} cards?',
      'confirmDeleteMultipleMessage': 'This action cannot be undone.',
      'duplicateCards': 'Duplicate Cards Found',
      'duplicateCardsMessage': '{count} cards already exist in "{deckName}".',
      'cardsWillBeMoved': '{count} cards will be moved.',
      'cardsWillBeCopied': '{count} cards will be copied.',
      'moveAnyway': 'Move Non-Duplicates',
      'copyAnyway': 'Copy Non-Duplicates',

      // Review screen
      'review': 'Review',
      'cardPosition': 'Card {current} / {total}',
      'reviewCompleted': 'Review Completed!',
      'correct': 'Correct: {count}',
      'incorrect': 'Incorrect: {count}',
      'finish': 'Finish',
      'reviewAgain': 'Review Again',
      'exitReview': 'Exit review?',
      'exitReviewMessage':
          'If you exit now, you will lose your current progress.',
      'exit': 'Exit',
      'noCards': 'No cards to review',

      // Settings screen
      'theme': 'Theme',
      'themeLight': 'Light',
      'themeDark': 'Dark',
      'themeSystem': 'System',
      'selectTheme': 'Select Theme',
      'language': 'Language',
      'selectLanguage': 'Select Language',
      'languageEnglish': 'English',
      'languageSpanish': 'Spanish',
      'languageSystem': 'System',
      'keepScreenOn': 'Keep Screen On',
      'keepScreenOnDescription': 'Prevent the screen from turning off',
      'sortBy': 'Sort by',
      'sortNameAsc': 'A → Z',
      'sortNameDesc': 'Z → A',
      'sortDateCreated': 'Newest First',

      // Predefined decks
      'contentLibrary': 'Content Library',
      'predefinedDecks': 'Predefined Decks',
      'loadPredefinedDecks': 'Load Predefined Decks',
      'selectDecksToLoad': 'Select decks to load',
      'englishDecks': 'English Decks',
      'spanishDecks': 'Spanish Decks',
      'cefrLevel': 'CEFR Level {level}',
      'loadSelected': 'Load Selected',
      'selectAllDecks': 'Select All',
      'deselectAllDecks': 'Deselect All',
      'loadingDecks': 'Loading decks...',
      'decksLoadedSuccess': 'Successfully loaded {count} deck(s)',
      'noDecksSelected': 'Please select at least one deck',
    },
    'es': {
      'about': 'Acerca de',
      'aboutDescription': '{app} es una aplicación de tarjetas didácticas de código abierto para aprender y memorizar. Creada con ❤️ usando Flutter.',
      // App general
      'appTitle': 'MyDeckCards',

      // Home screen
      'myDecks': 'Mis Mazos',
      'createDeck': 'Crear Mazo',
      'deckName': 'Nombre del Mazo',
      'cancel': 'Cancelar',
      'create': 'Crear',
      'close': 'Cerrar',
      'cardsCount': '{count} cartas',
      'emptyDecks': 'No hay mazos\nToca + para crear uno',
      'deckNameRequired': 'Por favor ingresa un nombre',
      'deckNameExists': 'Ya existe un mazo con este nombre',
      'confirmDeleteDeck': '¿Eliminar mazo?',
      'confirmDeleteDeckMessage':
          'Esto eliminará todas las cartas de este mazo. Esta acción no se puede deshacer.',
      'delete': 'Eliminar',
      'renameDeck': 'Renombrar Mazo',
      'newName': 'Nuevo Nombre',
      'rename': 'Renombrar',
      'changeIcon': 'Cambiar Icono',
      'selectIcon': 'Seleccionar Icono',
      'noIcon': 'Sin Icono',
      'archive': 'Archivar',
      'unarchive': 'Desarchivar',
      'archived': 'Archivado',
      'archivedDecks': 'Mazos Archivados',
      'noArchivedDecks': 'No hay mazos archivados',
      'unarchived': 'Desarchivado',
      'undo': 'Deshacer',

      // Drawer menu
      'settings': 'Configuración',
      'exportDecks': 'Exportar Mazos',
      'importDecks': 'Importar Mazos',

      // Export/Import
      'exportTitle': 'Exportar Mazos',
      'exportMessage': 'Esto exportará todos tus mazos a un archivo JSON.',
      'export': 'Exportar',
      'selectFolder': 'Selecciona dónde guardar el archivo',
      'exportSuccess': 'Exportación Exitosa',
      'exportSuccessMessage':
          'Se exportaron {deckCount} mazos con {cardCount} cartas en total a:',
      'exportError': 'Error de Exportación',
      'exportCancelled': 'Exportación cancelada',
      'importTitle': 'Importar Mazos',
      'importMessage':
          'Selecciona un archivo JSON para importar mazos.\n\nNota: Si existe un mazo con el mismo nombre, se renombrará automáticamente.',
      'import': 'Importar',
      'importSuccess': 'Importación Exitosa',
      'importSuccessMessage':
          'Se importaron {deckCount} mazos con {cardCount} cartas en total.',
      'importRenamed': 'Se renombraron {count} mazos para evitar conflictos.',
      'importError': 'Error de Importación',
      'importCancelled': 'Importación cancelada',
      'invalidJson': 'Archivo JSON inválido',
      'ok': 'OK',

      // Deck detail screen
      'addCard': 'Añadir Carta',
      'editCard': 'Editar Carta',
      'front': 'Frente (Palabra/Pregunta)',
      'back': 'Reverso (Significado/Respuesta)',
      'add': 'Añadir',
      'save': 'Guardar',
      'emptyDeck': 'No hay cartas\nToca + para añadir una',
      'frontRequired': 'Por favor ingresa el frente de la carta',
      'backRequired': 'Por favor ingresa el reverso de la carta',
      'cardExists': 'Ya existe una carta con este frente',
      'confirmDeleteCard': '¿Eliminar carta?',
      'confirmDeleteCardMessage': 'Esta acción no se puede deshacer.',
      'addAnother': 'Añadir Otra',
      'moveCard': 'Mover a Otro Mazo',
      'moveCardTitle': 'Mover Carta',
      'selectDestinationDeck': 'Selecciona el mazo de destino:',
      'move': 'Mover',
      'cardMoved': 'Carta movida exitosamente',
      'copyCard': 'Copiar a Otro Mazo',
      'copyCardTitle': 'Copiar Carta',
      'cardCopied': 'Carta copiada exitosamente',
      'selectMultiple': 'Selección Múltiple',
      'selected': 'seleccionadas',
      'selectAll': 'Seleccionar Todo',
      'cardsMoved': 'cartas movidas',
      'cardsCopied': 'cartas copiadas',
      'cardsDeleted': 'cartas eliminadas',
      'confirmDeleteMultiple': '¿Eliminar {count} cartas?',
      'confirmDeleteMultipleMessage': 'Esta acción no se puede deshacer.',
      'duplicateCards': 'Cartas Duplicadas Encontradas',
      'duplicateCardsMessage': '{count} cartas ya existen en "{deckName}".',
      'cardsWillBeMoved': '{count} cartas serán movidas.',
      'cardsWillBeCopied': '{count} cartas serán copiadas.',
      'moveAnyway': 'Mover No Duplicadas',
      'copyAnyway': 'Copiar No Duplicadas',

      // Review screen
      'review': 'Repaso',
      'cardPosition': 'Carta {current} / {total}',
      'reviewCompleted': '¡Repaso Completado!',
      'correct': 'Correctas: {count}',
      'incorrect': 'Incorrectas: {count}',
      'finish': 'Finalizar',
      'reviewAgain': 'Repasar de nuevo',
      'exitReview': '¿Salir del repaso?',
      'exitReviewMessage': 'Si sales ahora, perderás el progreso actual.',
      'exit': 'Salir',
      'noCards': 'No hay cartas para repasar',

      // Settings screen
      'theme': 'Tema',
      'themeLight': 'Claro',
      'themeDark': 'Oscuro',
      'themeSystem': 'Sistema',
      'selectTheme': 'Seleccionar Tema',
      'language': 'Idioma',
      'selectLanguage': 'Seleccionar Idioma',
      'languageEnglish': 'English',
      'languageSpanish': 'Español',
      'languageSystem': 'Sistema',
      'keepScreenOn': 'Mantener Pantalla Activa',
      'keepScreenOnDescription': 'Evitar que la pantalla se apague',
      'sortBy': 'Ordenar por',
      'sortNameAsc': 'A → Z',
      'sortNameDesc': 'Z → A',
      'sortDateCreated': 'Más Recientes',

      // Predefined decks
      'contentLibrary': 'Biblioteca de Contenido',
      'predefinedDecks': 'Mazos Predefinidos',
      'loadPredefinedDecks': 'Cargar Mazos Predefinidos',
      'selectDecksToLoad': 'Selecciona mazos para cargar',
      'englishDecks': 'Mazos de Inglés',
      'spanishDecks': 'Mazos de Español',
      'cefrLevel': 'Nivel MCER {level}',
      'loadSelected': 'Cargar Seleccionados',
      'selectAllDecks': 'Seleccionar Todo',
      'deselectAllDecks': 'Deseleccionar Todo',
      'loadingDecks': 'Cargando mazos...',
      'decksLoadedSuccess': 'Se cargaron exitosamente {count} mazo(s)',
      'noDecksSelected': 'Por favor selecciona al menos un mazo',
    },
  };

  String translate(String key, {Map<String, dynamic>? params}) {
    String translation = _localizedValues[locale.languageCode]?[key] ?? key;

    if (params != null) {
      params.forEach((paramKey, value) {
        translation = translation.replaceAll('{$paramKey}', value.toString());
      });
    }

    return translation;
  }

  // Helper getters for common translations
  String get appTitle => translate('appTitle');
  String get myDecks => translate('myDecks');
  String get settings => translate('settings');
  String get cancel => translate('cancel');
  String get ok => translate('ok');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
