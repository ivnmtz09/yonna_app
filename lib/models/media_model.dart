class MediaItemModel {
  final int id;
  final String title;
  final String description;
  final String mediaType; // audio, video
  final String fileUrl;
  final int duration; // en segundos
  final String? thumbnail;
  final String? category;

  MediaItemModel({
    required this.id,
    required this.title,
    required this.description,
    required this.mediaType,
    required this.fileUrl,
    required this.duration,
    this.thumbnail,
    this.category,
  });

  String get durationFormatted {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      mediaType: json['media_type'] ?? (json['file']?.toString().endsWith('.mp3') == true ? 'audio' : 'video'),
      fileUrl: json['file'] ?? json['file_url'] ?? json['url'] ?? '',
      duration: json['duration'] is int
          ? json['duration']
          : int.tryParse(json['duration']?.toString() ?? '0') ?? 0,
      thumbnail: json['thumbnail'] ?? json['cover_image'],
      category: json['category']?.toString(),
    );
  }
}

class MediaCollectionModel {
  final int id;
  final String title;
  final String description;
  final List<MediaItemModel> items;

  MediaCollectionModel({
    required this.id,
    required this.title,
    required this.description,
    this.items = const [],
  });

  factory MediaCollectionModel.fromJson(Map<String, dynamic> json) {
    List<MediaItemModel> list = [];
    if (json['media'] != null && json['media'] is List) {
      list = (json['media'] as List)
          .map((m) => MediaItemModel.fromJson(m))
          .toList();
    } else if (json['items'] != null && json['items'] is List) {
      list = (json['items'] as List)
          .map((m) => MediaItemModel.fromJson(m))
          .toList();
    }

    return MediaCollectionModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      items: list,
    );
  }
}
