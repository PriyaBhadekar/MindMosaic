class SongModel {
  final int id;
  final String title;
  final String? artist;
  final String? audioPath;
  final String? moodCategory;
  final int? durationSeconds;
  final String? createdAt;

  SongModel({
    required this.id,
    required this.title,
    this.artist,
    this.audioPath,
    this.moodCategory,
    this.durationSeconds,
    this.createdAt,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) => SongModel(
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    artist: json['artist'],
    audioPath: json['audioPath'],
    moodCategory: json['moodCategory'],
    durationSeconds: json['durationSeconds'],
    createdAt: json['createdAt'],
  );
}