import '../../domain/entities/mental_health_resource.dart';

class MentalHealthResourceModel extends MentalHealthResource {
  const MentalHealthResourceModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.contentUrl,
    super.thumbnail,
  });

  factory MentalHealthResourceModel.fromJson(Map<String, dynamic> json) {
    return MentalHealthResourceModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: json['type'],
      contentUrl: json['content_url'],
      thumbnail: json['thumbnail'],
    );
  }
}
