import 'package:dio/dio.dart';
import '../models/article_model.dart';

abstract class ArticleRemoteDataSource {
  Future<List<ArticleModel>> getArticles();
  Future<void> createArticle(String title, String content);
}

class ArticleRemoteDataSourceImpl implements ArticleRemoteDataSource {
  final Dio client;

  ArticleRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ArticleModel>> getArticles() async {
    final response = await client.get('/api/articles');
    return (response.data as List).map((e) => ArticleModel.fromJson(e)).toList();
  }

  @override
  Future<void> createArticle(String title, String content) async {
    await client.post('/admin/articles', data: {
      'title': title,
      'content': content,
    });
  }
}
