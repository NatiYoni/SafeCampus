import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.title,
    required super.content,
    required super.authorName,
    required super.createdAt,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      authorName: json['author_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
