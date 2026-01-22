import 'flashcard.dart';

class Deck {
  final String id;
  final String name;
  final String? icon; // Emoji icon for the deck
  final bool archived; // Whether the deck is archived
  final List<Flashcard> cards;

  Deck({
    required this.id,
    required this.name,
    this.icon,
    this.archived = false,
    List<Flashcard>? cards,
  }) : cards = cards ?? [];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'archived': archived,
      'cards': cards.map((card) => card.toJson()).toList(),
    };
  }

  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] as String?,
      archived: json['archived'] as bool? ?? false,
      cards:
          (json['cards'] as List?)
              ?.map((cardJson) => Flashcard.fromJson(cardJson))
              .toList() ??
          [],
    );
  }

  Deck copyWith({
    String? id,
    String? name,
    Object? icon = _undefined,
    bool? archived,
    List<Flashcard>? cards,
  }) {
    return Deck(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon == _undefined ? this.icon : icon as String?,
      archived: archived ?? this.archived,
      cards: cards ?? this.cards,
    );
  }
}

const Object _undefined = Object();
