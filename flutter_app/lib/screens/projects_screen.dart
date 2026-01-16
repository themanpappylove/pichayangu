import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class ProjectsScreen extends StatefulWidget {
  final int clientId;
  const ProjectsScreen({super.key, required this.clientId});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  final api = ApiService();
  late Future<List<Project>> _projectsFuture;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _projectsFuture = api.getProjects().then((all) => all.where((p) => p.clientId == widget.clientId).toList());
  }

  void _addProject() async {
    if (_nameController.text.isEmpty) return;
    await api.createProject(widget.clientId, _nameController.text);
    _nameController.clear();
    setState(() => _projectsFuture = api.getProjects().then((all) => all.where((p) => p.clientId == widget.clientId).toList()));
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projects')),
      body: FutureBuilder<List<Project>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No projects yet.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final project = snapshot.data![i];
              return ListTile(
                title: Text(project.name),
                trailing: IconButton(
                  icon: const Icon(Icons.photo),
                  onPressed: () => Navigator.pushNamed(context, '/media', arguments: project.id),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('New Project'),
            content: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(onPressed: _addProject, child: const Text('Create')),
            ],
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
