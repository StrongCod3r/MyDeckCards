import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import '../models/deck.dart';
import '../models/flashcard.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('flashcards.db');
    return _database!;
  }

  Future<void> resetDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> _initDB(String filePath) async {
    // Inicializar sqflite_ffi para plataformas desktop (Windows, Linux, macOS)
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE decks (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        icon TEXT,
        archived INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id TEXT PRIMARY KEY,
        deck_id TEXT NOT NULL,
        front TEXT NOT NULL,
        back TEXT NOT NULL,
        FOREIGN KEY (deck_id) REFERENCES decks (id) ON DELETE CASCADE
      )
    ''');

    // Índice para búsquedas más rápidas
    await db.execute('CREATE INDEX idx_cards_deck_id ON cards (deck_id)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Agregar columna icon a la tabla decks
      await db.execute('ALTER TABLE decks ADD COLUMN icon TEXT');
    }
    if (oldVersion < 3) {
      // Agregar columna archived a la tabla decks
      await db.execute(
        'ALTER TABLE decks ADD COLUMN archived INTEGER NOT NULL DEFAULT 0',
      );
    }
  }

  // OPERACIONES CON MAZOS

  Future<List<Deck>> getAllDecks() async {
    final db = await database;

    final decksResult = await db.query('decks', orderBy: 'name ASC');
    final cardsResult = await db.query('cards');

    // Crear un mapa de cartas por deck_id
    final Map<String, List<Flashcard>> cardsByDeck = {};
    for (var cardMap in cardsResult) {
      final deckId = cardMap['deck_id'] as String;
      final card = Flashcard(
        id: cardMap['id'] as String,
        front: cardMap['front'] as String,
        back: cardMap['back'] as String,
      );

      if (!cardsByDeck.containsKey(deckId)) {
        cardsByDeck[deckId] = [];
      }
      cardsByDeck[deckId]!.add(card);
    }

    // Crear los mazos con sus cartas
    return decksResult.map((deckMap) {
      final deckId = deckMap['id'] as String;
      return Deck(
        id: deckId,
        name: deckMap['name'] as String,
        icon: deckMap['icon'] as String?,
        archived: (deckMap['archived'] as int?) == 1,
        cards: cardsByDeck[deckId] ?? [],
      );
    }).toList();
  }

  Future<Deck?> getDeck(String deckId) async {
    final db = await database;

    final deckResult = await db.query(
      'decks',
      where: 'id = ?',
      whereArgs: [deckId],
    );

    if (deckResult.isEmpty) return null;

    final cardsResult = await db.query(
      'cards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );

    final cards = cardsResult.map((cardMap) {
      return Flashcard(
        id: cardMap['id'] as String,
        front: cardMap['front'] as String,
        back: cardMap['back'] as String,
      );
    }).toList();

    final deckMap = deckResult.first;
    return Deck(
      id: deckMap['id'] as String,
      name: deckMap['name'] as String,
      icon: deckMap['icon'] as String?,
      archived: (deckMap['archived'] as int?) == 1,
      cards: cards,
    );
  }

  Future<void> insertDeck(Deck deck) async {
    final db = await database;
    await db.insert('decks', {
      'id': deck.id,
      'name': deck.name,
      'icon': deck.icon,
      'archived': deck.archived ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateDeck(Deck deck) async {
    final db = await database;
    await db.update(
      'decks',
      {'name': deck.name, 'icon': deck.icon, 'archived': deck.archived ? 1 : 0},
      where: 'id = ?',
      whereArgs: [deck.id],
    );
  }

  Future<void> deleteDeck(String deckId) async {
    final db = await database;
    // Las cartas se eliminan automáticamente por CASCADE
    await db.delete('decks', where: 'id = ?', whereArgs: [deckId]);
  }

  // OPERACIONES CON CARTAS

  Future<List<Flashcard>> getCardsByDeck(String deckId) async {
    final db = await database;
    final result = await db.query(
      'cards',
      where: 'deck_id = ?',
      whereArgs: [deckId],
    );

    return result.map((cardMap) {
      return Flashcard(
        id: cardMap['id'] as String,
        front: cardMap['front'] as String,
        back: cardMap['back'] as String,
      );
    }).toList();
  }

  Future<void> insertCard(String deckId, Flashcard card) async {
    final db = await database;
    await db.insert('cards', {
      'id': card.id,
      'deck_id': deckId,
      'front': card.front,
      'back': card.back,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCard(Flashcard card, String deckId) async {
    final db = await database;
    await db.update(
      'cards',
      {'front': card.front, 'back': card.back},
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<void> deleteCard(String cardId) async {
    final db = await database;
    await db.delete('cards', where: 'id = ?', whereArgs: [cardId]);
  }

  // VALIDACIONES

  Future<bool> isDeckNameUnique(String name, {String? excludeDeckId}) async {
    final db = await database;
    final lowerName = name.toLowerCase().trim();

    String whereClause = 'LOWER(TRIM(name)) = ?';
    List<dynamic> whereArgs = [lowerName];

    if (excludeDeckId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeDeckId);
    }

    final result = await db.query(
      'decks',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return result.isEmpty;
  }

  Future<bool> isCardFrontUnique(
    String deckId,
    String front, {
    String? excludeCardId,
  }) async {
    final db = await database;
    final lowerFront = front.toLowerCase().trim();

    String whereClause = 'deck_id = ? AND LOWER(TRIM(front)) = ?';
    List<dynamic> whereArgs = [deckId, lowerFront];

    if (excludeCardId != null) {
      whereClause += ' AND id != ?';
      whereArgs.add(excludeCardId);
    }

    final result = await db.query(
      'cards',
      where: whereClause,
      whereArgs: whereArgs,
    );

    return result.isEmpty;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
