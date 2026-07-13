class GameScoreModel {
  final int id;
  final String gameType;
  final int score;
  final int? maxScore;

  final String? difficultyLevel;
  final int? durationSeconds;
  final String? playedAt;

  final double? percentageScore;
  final String? grade;

  // NEW
  final int? patientId;
  final String? patientName;

  GameScoreModel({
    required this.id,
    required this.gameType,
    required this.score,
    this.maxScore,
    this.difficultyLevel,
    this.durationSeconds,
    this.playedAt,
    this.percentageScore,
    this.grade,
    this.patientId,
    this.patientName,
  });

  factory GameScoreModel.fromJson(Map<String, dynamic> json) {
    return GameScoreModel(
      id: json['id'] ?? 0,
      gameType: json['gameType'] ?? '',
      score: json['score'] ?? 0,
      maxScore: json['maxScore'],

      difficultyLevel: json['difficultyLevel'],
      durationSeconds: json['durationSeconds'],
      playedAt: json['playedAt'],

      percentageScore: (json['percentageScore'] as num?)?.toDouble(),
      grade: json['grade'],

      patientId: json['patientId'],
      patientName: json['patientName'],
    );
  }

  double get progress {
    if (maxScore == null || maxScore == 0) return 0;
    return score / maxScore!;
  }

  String get formattedScore {
    if (maxScore == null) return "$score";
    return "$score/$maxScore";
  }
}

class FlashcardQuestion {
  final int memoryId;
  final String? imagePath;
  final String? imageUrl;
  final String question;
  final String? description;
  final List<String> options;
  final String correctAnswer;
  final String? category;
  final String? relationInfo;

  FlashcardQuestion({
    required this.memoryId,
    this.imagePath,
    this.imageUrl,
    required this.question,
    this.description,
    required this.options,
    required this.correctAnswer,
    this.category,
    this.relationInfo,
  });

  factory FlashcardQuestion.fromJson(Map<String, dynamic> json) {
    return FlashcardQuestion(
      memoryId: json['memoryId'] ?? 0,
      imagePath: json['imagePath'],
      imageUrl: json['imageUrl'],
      question: json['question'] ?? 'Who is this person?',
      description: json['description'],
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      category: json['category'],
      relationInfo: json['relationInfo'],
    );
  }
}