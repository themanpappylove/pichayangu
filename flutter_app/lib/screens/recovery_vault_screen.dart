import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class RecoveryVaultScreen extends StatefulWidget {
  const RecoveryVaultScreen({super.key});

  @override
  State<RecoveryVaultScreen> createState() => _RecoveryVaultScreenState();
}

class _RecoveryVaultScreenState extends State<RecoveryVaultScreen> {
  final api = ApiService();
  late Future<List<DeletedFile>> _deletedFuture;

  @override
  void initState() {
    super.initState();
    _deletedFuture = api.getDeletedFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recovery Vault')),
      body: FutureBuilder<List<DeletedFile>>(
        future: _deletedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Your Recovery Vault is empty.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final deleted = snapshot.data![i];
              return ListTile(
                title: Text(deleted.media.fileName),
                subtitle: Text('Expires: ${deleted.expiry.toString().split(' ')[0]}'),
                trailing: deleted.isExpired
                    ? const Text('Expired', style: TextStyle(color: Colors.red))
                    : ElevatedButton(
                        onPressed: () async {
                          await api.restoreMedia(deleted.media.id);
                          setState(() => _deletedFuture = api.getDeletedFiles());
                        },
                        child: const Text('Restore'),
                      ),
              );
            },
          );
        },
      ),
    );
  }
}
