import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../injection_container.dart';
import '../bloc/article_bloc.dart';
import '../bloc/article_event.dart';
import '../bloc/article_state.dart';

class CreateArticlePage extends StatefulWidget {
  const CreateArticlePage({super.key});

  @override
  State<CreateArticlePage> createState() => _CreateArticlePageState();
}

class _CreateArticlePageState extends State<CreateArticlePage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ArticleBloc>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Article')),
        body: BlocConsumer<ArticleBloc, ArticleState>(
          listener: (context, state) {
            if (state is ArticleCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Article created successfully')),
              );
              Navigator.pop(context, true); // Return true to refresh previous screen
            } else if (state is ArticleError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
            }
          },
          builder: (context, state) {
            return Stack(
              children: [
                SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _titleController,
                          decoration: const InputDecoration(labelText: 'Title'),
                          validator: (value) =>
                              (value == null || value.isEmpty) ? 'Enter a title' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _contentController,
                          decoration: const InputDecoration(labelText: 'Content'),
                          maxLines: 8,
                           validator: (value) =>
                              (value == null || value.isEmpty) ? 'Enter content' : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state is ArticleLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      context.read<ArticleBloc>().add(
                                            CreateArticleRequested(
                                              _titleController.text,
                                              _contentController.text,
                                            ),
                                          );
                                    }
                                  },
                            child: const Text('Publish'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                ),
                if (state is ArticleLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            );
          },
        ),
      ),
    );
  }
}
