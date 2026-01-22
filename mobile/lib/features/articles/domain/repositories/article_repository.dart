import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/article.dart';

abstract class ArticleRepository {
  Future<Either<Failure, List<Article>>> getArticles();
  Future<Either<Failure, void>> createArticle(String title, String content);
}
