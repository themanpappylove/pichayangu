import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class FileDetailScreen extends StatefulWidget {
  final int fileId;
  const FileDetailScreen({super.key, required this.fileId});

  @override
  State<FileDetailScreen> createState() => _FileDetailScreenState();
}

class _FileDetailScreenState extends State<FileDetailScreen> with SingleTickerProviderStateMixin {
  final api = ApiService();
  late TabController _tabController;
  late Future<MediaFile?> _fileFuture;
  late Future<List<FileVersion>> _versionsFuture;
  late Future<List<ShareLink>> _sharesFuture;
  late Future<List<MediaFile>> _duplicatesFuture;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fileFuture = api.getMediaDetail(widget.fileId);
    _versionsFuture = api.getVersions(widget.fileId);
    _sharesFuture = api.getShareLinks(widget.fileId);
    _duplicatesFuture = api.getDuplicates(widget.fileId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Details'),
        bottom: TabBar(controller: _tabController, tabs: const [
          Tab(icon: Icon(Icons.info), text: 'Info'),
          Tab(icon: Icon(Icons.history), text: 'Versions'),
          Tab(icon: Icon(Icons.share), text: 'Share'),
          Tab(icon: Icon(Icons.warning), text: 'Duplicates'),
        ]),
      ),
      body: FutureBuilder<MediaFile?>(
        future: _fileFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final media = snapshot.data!;
          return TabBarView(controller: _tabController, children: [
            // Info tab
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('File: ${media.fileName}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Type: ${media.mediaType}'),
                        Text('Status: ${media.status}'),
                        Text('Uploaded: ${media.createdAt.toString().split(' ')[0]}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () async {
                            final confirmed = await showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Delete?'),
                                content: const Text('Move to Recovery Vault?'),
                                actions: [
                                  TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                  ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                                ],
                              ),
                            );
                            if (confirmed == true) {
                              await api.softDeleteMedia(widget.fileId);
                              if (mounted) Navigator.pop(context);
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          child: const Text('Delete File', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Versions tab
            FutureBuilder<List<FileVersion>>(
              future: _versionsFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.isEmpty) return const Center(child: Text('No versions yet.'));
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final v = snapshot.data![i];
                    return ListTile(
                      title: Text('Version ${v.versionNumber}'),
                      subtitle: Text(v.createdAt.toString().split(' ')[0]),
                      trailing: IconButton(icon: const Icon(Icons.download), onPressed: () {}),
                    );
                  },
                );
              },
            ),
            // Share tab
            FutureBuilder<List<ShareLink>>(
              future: _sharesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () async {
                          final share = await api.createShareLink(widget.fileId, expiresInDays: 7);
                          if (share != null) setState(() => _sharesFuture = api.getShareLinks(widget.fileId));
                        },
                        child: const Text('Create Share Link'),
                      ),
                    ),
                    Expanded(
                      child: snapshot.data!.isEmpty
                          ? const Center(child: Text('No share links yet.'))
                          : ListView.builder(
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, i) {
                                final s = snapshot.data![i];
                                return ListTile(
                                  title: Text(s.token.substring(0, 8)),
                                  subtitle: Text('${s.permission} • Accessed: ${s.accessCount}x'),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await api.deleteShareLink(s.id);
                                      setState(() => _sharesFuture = api.getShareLinks(widget.fileId));
                                    },
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
            // Duplicates tab
            FutureBuilder<List<MediaFile>>(
              future: _duplicatesFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                if (snapshot.data!.isEmpty) return const Center(child: Text('No duplicates found.'));
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final d = snapshot.data![i];
                    return ListTile(title: Text(d.fileName), subtitle: Text('ID: ${d.id}'));
                  },
                );
              },
            ),
          ]);
        },
      ),
    );
  }
}
