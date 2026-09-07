class VocabularyCategoryModel {
  final int id;
  final String name;
  final String slug;
  final String? icon;

  VocabularyCategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.icon,
  });

  factory VocabularyCategoryModel.fromJson(Map<String, dynamic> json) {
    return VocabularyCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      icon: json['icon'],
    );
  }
}

class VocabularyEntryModel {
  final int id;
  final String spanishTerm;
  final String wayuunaikiTranslation;
  final String? phoneticTranscription;
  final String? audioPronunciation;
  final String? image;
  final List<String> examples;
  final String? category;
  final String? difficulty;
  int masteryLevel; // 0: Vista, 1: Aprendiendo, 2: Familiar, 3: Dominada
  int reviewCount;
  DateTime? nextReviewDate;

  VocabularyEntryModel({
    required this.id,
    required this.spanishTerm,
    required this.wayuunaikiTranslation,
    this.phoneticTranscription,
    this.audioPronunciation,
    this.image,
    this.examples = const [],
    this.category,
    this.difficulty,
    this.masteryLevel = 0,
    this.reviewCount = 0,
    this.nextReviewDate,
  });

  String get masteryLevelName {
    switch (masteryLevel) {
      case 0:
        return 'Vista';
      case 1:
        return 'Aprendiendo';
      case 2:
        return 'Familiar';
      case 3:
        return 'Dominada';
      default:
        return 'Nueva';
    }
  }

  factory VocabularyEntryModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedExamples = [];
    if (json['examples'] != null) {
      if (json['examples'] is List) {
        parsedExamples = (json['examples'] as List)
            .map((e) => e is Map ? (e['text'] ?? e['sentence'] ?? e.toString()).toString() : e.toString())
            .toList();
      } else if (json['examples'] is String) {
        parsedExamples = [json['examples']];
      }
    }

    return VocabularyEntryModel(
      id: json['id'] ?? 0,
      spanishTerm: json['spanish_term'] ?? json['spanish'] ?? '',
      wayuunaikiTranslation: json['wayuunaiki_translation'] ?? json['wayuunaiki'] ?? '',
      phoneticTranscription: json['phonetic_transcription'] ?? json['phonetic'],
      audioPronunciation: json['audio_pronunciation'] ?? json['audio'],
      image: json['image'],
      examples: parsedExamples,
      category: json['category_name'] ?? json['category']?.toString(),
      difficulty: json['difficulty'],
      masteryLevel: json['mastery_level'] ?? json['progress']?['mastery_level'] ?? 0,
      reviewCount: json['review_count'] ?? json['progress']?['review_count'] ?? 0,
      nextReviewDate: json['next_review_date'] != null
          ? DateTime.tryParse(json['next_review_date'])
          : null,
    );
  }
}
