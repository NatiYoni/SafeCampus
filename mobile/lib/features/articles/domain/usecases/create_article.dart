import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/article_repository.dart';

class CreateArticle {
  final ArticleRepository repository;

  CreateArticle(this.repository);

  Future<Either<Failure, void>> call(String title, String content) async {
    return await repository.createArticle(title, content);
  }
}
