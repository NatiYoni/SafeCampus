import 'package:equatable/equatable.dart';
import '../../domain/entities/article.dart';

abstract class ArticleState extends Equatable {
  const ArticleState();
  @override
  List<Object> get props => [];
}

class ArticleInitial extends ArticleState {}
class ArticleLoading extends ArticleState {}
class ArticlesLoaded extends ArticleState {
  final List<Article> articles;
  const ArticlesLoaded(this.articles);
  @override
  List<Object> get props => [articles];
}
class ArticleCreated extends ArticleState {} // Success state for creation
class ArticleError extends ArticleState {
  final String message;
  const ArticleError(this.message);
  @override
  List<Object> get props => [message];
}
