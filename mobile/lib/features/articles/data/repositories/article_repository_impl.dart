import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/article_repository.dart';
import '../datasources/article_remote_data_source.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final ArticleRemoteDataSource remoteDataSource;

  ArticleRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Article>>> getArticles() async {
    try {
      final articles = await remoteDataSource.getArticles();
      return Right(articles);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createArticle(String title, String content) async {
    try {
      await remoteDataSource.createArticle(title, content);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
