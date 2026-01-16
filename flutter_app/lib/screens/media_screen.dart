import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class MediaScreen extends StatefulWidget {
  final int projectId;
  const MediaScreen({super.key, required this.projectId});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final api = ApiService();
  late Future<List<MediaFile>> _mediaFuture;
  final ImagePicker _picker = ImagePicker();
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _mediaFuture = api.getMedia().then((all) => all.where((m) => m.projectId == widget.projectId && !m.isDeleted).toList());
  }

  void _pickAndUpload() async {
    final image = await _picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    setState(() => _uploading = true);
    final media = await api.uploadMedia(widget.projectId, image.path, 'image', status: 'raw');
    setState(() => _uploading = false);

    if (media != null) {
      setState(() => _mediaFuture = api.getMedia().then((all) => all.where((m) => m.projectId == widget.projectId && !m.isDeleted).toList()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Media Gallery')),
      body: FutureBuilder<List<MediaFile>>(
        future: _mediaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No media files yet. Upload your first photo!'));
          }
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 1),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final media = snapshot.data![i];
              return Card(
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/file_detail', arguments: media.id),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(media.mediaType == 'image' ? Icons.image : Icons.videocam, size: 40),
                        const SizedBox(height: 8),
                        Text(media.fileName, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                        const SizedBox(height: 4),
                        Chip(label: Text(media.status), backgroundColor: Colors.grey.shade300),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: _uploading
          ? null
          : FloatingActionButton(
              onPressed: _pickAndUpload,
              child: const Icon(Icons.add_a_photo),
            ),
    );
  }
}
