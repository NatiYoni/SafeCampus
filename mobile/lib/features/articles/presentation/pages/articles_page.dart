import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';
import 'create_article_page.dart';

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ArticleBloc>()..add(FetchArticlesRequested()),
      child: Builder( // Added Builder to ensure context has ArticleBloc
          builder: (context) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Campus News'),
              ),
              body: BlocBuilder<ArticleBloc, ArticleState>(
                builder: (context, state) {
                  if (state is ArticleInitial || state is ArticleLoading) { // Handle Initial
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ArticlesLoaded) {
              if (state.articles.isEmpty) {
                 return const Center(child: Text("No articles found."));
              }
              return ListView.builder(
                itemCount: state.articles.length,
                itemBuilder: (context, index) {
                  final article = state.articles[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ExpansionTile(
                      title: Text(article.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(article.createdAt.toLocal().toString().split('.')[0]),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(article.content),
                        ),
                      ],
                    ),
                  );
                },
              );
            } else if (state is ArticleError) {
              return Center(child: Text("Error: ${state.message}"));
            }
            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            // Allow both 'admin' and 'super_admin' to see the create button
            if (state is AuthAuthenticated && (state.user.role == 'admin' || state.user.role == 'super_admin')) {
              return FloatingActionButton(
                onPressed: () async {
                  // We can pass the bloc to the next page, or just await result
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateArticlePage()),
                  );
                  if (result == true) {
                     // Refresh list
                     if (context.mounted) {
                       context.read<ArticleBloc>().add(FetchArticlesRequested());
                     }
                  }
                },
                child: const Icon(Icons.add),
              );
            }
            return const SizedBox.shrink();
          },
        ),
       );
      }
      ),
    );
  }
}
