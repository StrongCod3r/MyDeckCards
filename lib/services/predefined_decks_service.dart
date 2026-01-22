import 'package:flutter/services.dart';
import 'dart:convert';

/// Information about a predefined deck
class PredefinedDeckInfo {
  final String id;
  final String assetPath;
  final String name;
  final String icon;
  final String level;
  final String language;

  const PredefinedDeckInfo({
    required this.id,
    required this.assetPath,
    required this.name,
    required this.icon,
    required this.level,
    required this.language,
  });
}

/// Service for managing predefined vocabulary decks
class PredefinedDecksService {
  /// List of all available predefined decks
  static const List<PredefinedDeckInfo> _availableDecks = [
    // English decks
    PredefinedDeckInfo(
      id: 'english_a1',
      assetPath: 'assets/predefined_decks/english/english_a1.json',
      name: 'English A1',
      icon: '🇬🇧',
      level: 'A1',
      language: 'english',
    ),
    PredefinedDeckInfo(
      id: 'english_a2',
      assetPath: 'assets/predefined_decks/english/english_a2.json',
      name: 'English A2',
      icon: '📘',
      level: 'A2',
      language: 'english',
    ),
    PredefinedDeckInfo(
      id: 'english_b1',
      assetPath: 'assets/predefined_decks/english/english_b1.json',
      name: 'English B1',
      icon: '📗',
      level: 'B1',
      language: 'english',
    ),
    PredefinedDeckInfo(
      id: 'english_b2',
      assetPath: 'assets/predefined_decks/english/english_b2.json',
      name: 'English B2',
      icon: '📙',
      level: 'B2',
      language: 'english',
    ),
    PredefinedDeckInfo(
      id: 'english_c1',
      assetPath: 'assets/predefined_decks/english/english_c1.json',
      name: 'English C1',
      icon: '📕',
      level: 'C1',
      language: 'english',
    ),
    // Spanish decks
    PredefinedDeckInfo(
      id: 'spanish_a1',
      assetPath: 'assets/predefined_decks/spanish/spanish_a1.json',
      name: 'Español A1',
      icon: '🇪🇸',
      level: 'A1',
      language: 'spanish',
    ),
    PredefinedDeckInfo(
      id: 'spanish_a2',
      assetPath: 'assets/predefined_decks/spanish/spanish_a2.json',
      name: 'Español A2',
      icon: '📚',
      level: 'A2',
      language: 'spanish',
    ),
    PredefinedDeckInfo(
      id: 'spanish_b1',
      assetPath: 'assets/predefined_decks/spanish/spanish_b1.json',
      name: 'Español B1',
      icon: '🎓',
      level: 'B1',
      language: 'spanish',
    ),
    PredefinedDeckInfo(
      id: 'spanish_b2',
      assetPath: 'assets/predefined_decks/spanish/spanish_b2.json',
      name: 'Español B2',
      icon: '🌟',
      level: 'B2',
      language: 'spanish',
    ),
    PredefinedDeckInfo(
      id: 'spanish_c1',
      assetPath: 'assets/predefined_decks/spanish/spanish_c1.json',
      name: 'Español C1',
      icon: '👑',
      level: 'C1',
      language: 'spanish',
    ),
  ];

  /// Get list of all available predefined decks
  List<PredefinedDeckInfo> getAvailableDecks() {
    return _availableDecks;
  }

  /// Get predefined decks filtered by language
  List<PredefinedDeckInfo> getDecksByLanguage(String language) {
    return _availableDecks.where((deck) => deck.language == language).toList();
  }

  /// Load a predefined deck from assets
  /// Returns the JSON data as a Map
  Future<Map<String, dynamic>> loadDeckFromAsset(String assetPath) async {
    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      return jsonData;
    } catch (e) {
      throw Exception('Failed to load deck from $assetPath: $e');
    }
  }

  /// Load a predefined deck by ID
  Future<Map<String, dynamic>> loadDeckById(String id) async {
    final deckInfo = _availableDecks.firstWhere(
      (deck) => deck.id == id,
      orElse: () => throw Exception('Deck with id $id not found'),
    );
    return loadDeckFromAsset(deckInfo.assetPath);
  }

  /// Load multiple predefined decks by their IDs
  Future<List<Map<String, dynamic>>> loadDecksByIds(List<String> ids) async {
    final List<Map<String, dynamic>> decks = [];
    for (final id in ids) {
      try {
        final deck = await loadDeckById(id);
        decks.add(deck);
      } catch (e) {
        // Continue loading other decks even if one fails
        // Log error but don't throw - allow other decks to load
        rethrow;
      }
    }
    return decks;
  }
}
