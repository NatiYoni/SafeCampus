import 'package:equatable/equatable.dart';

class Article extends Equatable {
  final String id;
  final String title;
  final String content;
  final String authorName;
  final DateTime createdAt;

  const Article({
    required this.id,
    required this.title,
    required this.content,
    required this.authorName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, title, content, authorName, createdAt];
}
