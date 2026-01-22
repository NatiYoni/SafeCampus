import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/create_article.dart';
import '../../domain/usecases/get_articles.dart';
import 'article_event.dart';
import 'article_state.dart';

class ArticleBloc extends Bloc<ArticleEvent, ArticleState> {
  final GetArticles getArticles;
  final CreateArticle createArticle;

  ArticleBloc({
    required this.getArticles,
    required this.createArticle,
  }) : super(ArticleInitial()) {
    on<FetchArticlesRequested>((event, emit) async {
      emit(ArticleLoading());
      final result = await getArticles(NoParams());
      result.fold(
        (failure) => emit(ArticleError(failure.message)), // Assuming Failure has a message property or map failure to string
        (articles) => emit(ArticlesLoaded(articles)),
      );
    });

    on<CreateArticleRequested>((event, emit) async {
      emit(ArticleLoading());
      final result = await createArticle(event.title, event.content);
      result.fold(
        (failure) => emit(ArticleError(failure.message)),
        (_) {
             emit(ArticleCreated());
             add(FetchArticlesRequested()); // Reload list after creation
        },
      );
    });
  }
}
