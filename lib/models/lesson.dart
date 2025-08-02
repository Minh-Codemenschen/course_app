class Lesson {
  final String name;
  final String? pdf;
  final List<String> audio;
  final bool isDownloaded;

  Lesson({
    required this.name,
    this.pdf,
    required this.audio,
    this.isDownloaded = false,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      name: json['name'] ?? '',
      pdf: json['pdf'],
      audio: List<String>.from(json['audio'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'pdf': pdf,
      'audio': audio,
    };
  }

  Lesson copyWith({
    String? name,
    String? pdf,
    List<String>? audio,
    bool? isDownloaded,
  }) {
    return Lesson(
      name: name ?? this.name,
      pdf: pdf ?? this.pdf,
      audio: audio ?? this.audio,
      isDownloaded: isDownloaded ?? this.isDownloaded,
    );
  }
} 