import 'package:equatable/equatable.dart';
import '../../domain/entities/article.dart';

abstract class ArticleEvent extends Equatable {
  const ArticleEvent();
  @override
  List<Object> get props => [];
}

class FetchArticlesRequested extends ArticleEvent {}

class CreateArticleRequested extends ArticleEvent {
  final String title;
  final String content;

  const CreateArticleRequested(this.title, this.content);

  @override
  List<Object> get props => [title, content];
}
