class MemoryModel {

  final int id;
  final String title;
  final String? description;
  final String? imagePath;
  final String? imageUrl;
  final String? relationInfo;
  final String? category;
  final String? tags;
  final String? createdAt;

  MemoryModel({
    required this.id,
    required this.title,
    this.description,
    this.imagePath,
    this.imageUrl,
    this.relationInfo,
    this.category,
    this.tags,
    this.createdAt,
  });

  factory MemoryModel.fromJson(Map<String, dynamic> json) {

    String? imagePath = json['imagePath'];

    if (imagePath != null && imagePath.isNotEmpty) {

      imagePath =
      'http://localhost:8080/$imagePath';
    }

    return MemoryModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'],
      imagePath: json['imagePath'],
      imageUrl: json['imageUrl'],
      relationInfo: json['relationInfo'],
      category: json['category'],
      tags: json['tags'],
      createdAt: json['createdAt'],
    );
  }
}