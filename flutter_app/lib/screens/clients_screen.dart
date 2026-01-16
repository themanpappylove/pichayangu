import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final api = ApiService();
  late Future<List<Client>> _clientsFuture;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _clientsFuture = api.getClients();
  }

  void _addClient() async {
    if (_nameController.text.isEmpty) return;
    await api.createClient(_nameController.text);
    _nameController.clear();
    setState(() => _clientsFuture = api.getClients());
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clients')),
      body: FutureBuilder<List<Client>>(
        future: _clientsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No clients yet. Create your first client!'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final client = snapshot.data![i];
              return ListTile(
                title: Text(client.name),
                subtitle: Text('Created: ${client.createdAt.toString().split(' ')[0]}'),
                trailing: IconButton(
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: () => Navigator.pushNamed(context, '/projects', arguments: client.id),
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
            title: const Text('New Client'),
            content: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(onPressed: _addClient, child: const Text('Create')),
            ],
          ),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
