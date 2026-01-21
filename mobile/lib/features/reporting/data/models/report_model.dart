import '../../domain/entities/report.dart';

class ReportModel extends Report {
  const ReportModel({
    required super.id,
    required super.userId,
    super.userName,
    required super.category,
    required super.description,
    required super.isAnonymous,
    required super.status,
    required super.timestamp,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      userId: json['user_id'] ?? "",
      userName: json['user_name'], // Deserialize user_name
      category: json['category'],
      description: json['description'],
      isAnonymous: json['is_anonymous'],
      status: json['status'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}
