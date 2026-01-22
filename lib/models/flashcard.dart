class Flashcard {
  final String id;
  final String front;
  final String back;

  Flashcard({
    required this.id,
    required this.front,
    required this.back,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'front': front,
      'back': back,
    };
  }

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      id: json['id'],
      front: json['front'],
      back: json['back'],
    );
  }

  Flashcard copyWith({
    String? id,
    String? front,
    String? back,
  }) {
    return Flashcard(
      id: id ?? this.id,
      front: front ?? this.front,
      back: back ?? this.back,
    );
  }
}
