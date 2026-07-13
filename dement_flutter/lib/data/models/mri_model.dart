class MriResultModel {
  final int id;
  final String imagePath;
  final bool? dementiaDetected;
  final String? dementiaStage;
  final double? confidenceScore;
  final String processingStatus;
  final String? createdAt;

  MriResultModel({
    required this.id,
    required this.imagePath,
    this.dementiaDetected,
    this.dementiaStage,
    this.confidenceScore,
    required this.processingStatus,
    this.createdAt,
  });

  factory MriResultModel.fromJson(Map<String, dynamic> json) => MriResultModel(
    id: json['id'] ?? 0,
    imagePath: json['imagePath'] ?? '',
    dementiaDetected: json['dementiaDetected'],
    dementiaStage: json['dementiaStage'],
    confidenceScore: json['confidenceScore']?.toDouble(),
    processingStatus: json['processingStatus'] ?? 'PENDING',
    createdAt: json['createdAt'],
  );
}