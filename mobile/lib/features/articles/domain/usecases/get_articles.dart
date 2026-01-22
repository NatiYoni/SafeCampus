import 'package:dartz/dartz.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/error/failures.dart';
import '../entities/article.dart';
import '../repositories/article_repository.dart';

class GetArticles implements UseCase<List<Article>, NoParams> {
  final ArticleRepository repository;

  GetArticles(this.repository);

  @override
  Future<Either<Failure, List<Article>>> call(NoParams params) async {
    return await repository.getArticles();
  }
}
