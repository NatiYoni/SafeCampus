import 'package:equatable/equatable.dart';

class MentalHealthResource extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type; // ARTICLE, HOTLINE, VIDEO
  final String contentUrl;
  final String? thumbnail;

  const MentalHealthResource({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.contentUrl,
    this.thumbnail,
  });

  @override
  List<Object?> get props => [id, title, description, type, contentUrl, thumbnail];
}
