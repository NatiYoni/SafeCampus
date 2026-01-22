import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../bloc/mental_health_bloc.dart';
import '../bloc/mental_health_event.dart';
import '../bloc/mental_health_state.dart';
import '../../domain/entities/mental_health_resource.dart';

class MentalHealthPage extends StatefulWidget {
  const MentalHealthPage({super.key});

  @override
  State<MentalHealthPage> createState() => _MentalHealthPageState();
}

class _MentalHealthPageState extends State<MentalHealthPage> {
  @override
  void initState() {
    super.initState();
    // Dispatch event to load data
    context.read<MentalHealthBloc>().add(LoadMentalHealthResources());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mental Health Resources')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/mental-health/chat');
        },
        icon: const Icon(Icons.support_agent),
        label: const Text('AI Companion'),
        backgroundColor: Colors.teal,
      ),
      body: BlocBuilder<MentalHealthBloc, MentalHealthState>(

        builder: (context, state) {
          if (state is MentalHealthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is MentalHealthError) {
            return Center(child: Text('Error: ${state.message}'));
          } else if (state is MentalHealthLoaded) {
            if (state.resources.isEmpty) {
              return const Center(child: Text('No resources available at the moment.'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.resources.length,
              itemBuilder: (context, index) {
                final resource = state.resources[index];
                return _buildResourceCard(context, resource);
              },
            );
          }
          return const Center(child: Text('Initialize to load resources'));
        },
      ),
    );
  }

  Widget _buildResourceCard(BuildContext context, MentalHealthResource resource) {
    IconData icon;
    Color color;

    switch (resource.type) {
      case 'HOTLINE':
        icon = Icons.phone_in_talk;
        color = Colors.redAccent;
        break;
      case 'VIDEO':
        icon = Icons.play_circle_fill;
        color = Colors.blueAccent;
        break;
      case 'ARTICLE':
      default:
        icon = Icons.article;
        color = Colors.green;
        break;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(icon, color: color),
        ),
        title: Text(resource.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(resource.description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _launchURL(resource.contentUrl),
      ),
    );
  }

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url)) {
      if (urlString.startsWith("tel:")) {
         // Attempt to launch tel specifically if generic fails
         // Usually redundant but safe
      }
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not launch $urlString')));
    }
  }
}
