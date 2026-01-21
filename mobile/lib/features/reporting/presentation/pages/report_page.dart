import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/reporting_bloc.dart';
import '../bloc/reporting_event.dart';
import '../bloc/reporting_state.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();
  String _category = 'BULLYING';
  final _descriptionController = TextEditingController();
  bool _isAnonymous = false;

  final List<String> _categories = ['BULLYING', 'THEFT', 'HARASSMENT', 'HAZARD', 'OTHER'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report Incident')),
      body: BlocListener<ReportingBloc, ReportingState>(
        listener: (context, state) {
          if (state is ReportingSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Report submitted successfully'), backgroundColor: Colors.green),
            );
            context.pop();
          } else if (state is ReportingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _category = newValue!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Submit Anonymously'),
                  value: _isAnonymous,
                  onChanged: (bool value) {
                    setState(() {
                      _isAnonymous = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: BlocBuilder<ReportingBloc, ReportingState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed: state is ReportingLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<ReportingBloc>().add(
                                        SubmitReportRequested(
                                          userId: _isAnonymous ? "" : "user-123", // TODO: Get actual user ID
                                          category: _category,
                                          description: _descriptionController.text,
                                          isAnonymous: _isAnonymous,
                                        ),
                                      );
                                }
                              },
                        child: state is ReportingLoading
                            ? const CircularProgressIndicator()
                            : const Text('Submit Report'),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }
}
