import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/reporting_bloc.dart';
import '../bloc/reporting_event.dart';
import '../bloc/reporting_state.dart';

class ReportingPage extends StatefulWidget {
  const ReportingPage({super.key});

  @override
  State<ReportingPage> createState() => _ReportingPageState();
}

class _ReportingPageState extends State<ReportingPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'HAZARD';
  bool _isAnonymous = false;

  final List<String> _categories = ['BULLYING', 'THEFT', 'HARASSMENT', 'HAZARD', 'OTHER'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: BlocListener<ReportingBloc, ReportingState>(
        listener: (context, state) {
          if (state is ReportingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report submitted successfully')));
            context.pop();
          } else if (state is ReportingError) {
             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (value) => setState(() => _selectedCategory = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 5,
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a description' : null,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Submit Anonymously'),
                  value: _isAnonymous,
                  onChanged: (value) => setState(() => _isAnonymous = value),
                ),
                const SizedBox(height: 24),
                BlocBuilder<ReportingBloc, ReportingState>(
                  builder: (context, state) {
                    if (state is ReportingLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // TODO: Use real User ID from Auth Bloc
                          context.read<ReportingBloc>().add(SubmitReportRequested(
                            userId: _isAnonymous ? "anon" : "user-123",
                            category: _selectedCategory,
                            description: _descriptionController.text,
                            isAnonymous: _isAnonymous,
                          ));
                        }
                      },
                      child: const Text('Submit Report'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
