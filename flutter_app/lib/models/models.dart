class User {
  final int id;
  final String username;
  final String email;

  User({required this.id, required this.username, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
    );
  }
}

class Client {
  final int id;
  final String name;
  final DateTime createdAt;

  Client({required this.id, required this.name, required this.createdAt});

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name};
  }
}

class Project {
  final int id;
  final int clientId;
  final String name;
  final DateTime createdAt;

  Project({
    required this.id,
    required this.clientId,
    required this.name,
    required this.createdAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      clientId: json['client'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'client': clientId, 'name': name};
  }
}

class MediaFile {
  final int id;
  final int projectId;
  final String fileName;
  final String mediaType; // image or video
  final String status; // raw, edited, final
  final bool isDeleted;
  final String? fileUrl;
  final DateTime createdAt;
  final List<FileVersion>? versions;
  final List<ShareLink>? shareLinks;

  MediaFile({
    required this.id,
    required this.projectId,
    required this.fileName,
    required this.mediaType,
    required this.status,
    required this.isDeleted,
    this.fileUrl,
    required this.createdAt,
    this.versions,
    this.shareLinks,
  });

  factory MediaFile.fromJson(Map<String, dynamic> json) {
    return MediaFile(
      id: json['id'] as int,
      projectId: json['project'] as int,
      fileName: (json['file'] as String).split('/').last,
      mediaType: json['media_type'] as String,
      status: json['status'] as String,
      isDeleted: json['is_deleted'] as bool,
      fileUrl: json['file'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      versions: (json['versions'] as List?)
          ?.map((v) => FileVersion.fromJson(v as Map<String, dynamic>))
          .toList(),
      shareLinks: (json['share_links'] as List?)
          ?.map((s) => ShareLink.fromJson(s as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FileVersion {
  final int id;
  final int versionNumber;
  final String fileUrl;
  final String? note;
  final DateTime createdAt;

  FileVersion({
    required this.id,
    required this.versionNumber,
    required this.fileUrl,
    this.note,
    required this.createdAt,
  });

  factory FileVersion.fromJson(Map<String, dynamic> json) {
    return FileVersion(
      id: json['id'] as int,
      versionNumber: json['version_number'] as int,
      fileUrl: json['file'] as String,
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}

class ShareLink {
  final int id;
  final String token;
  final String permission; // view or download
  final DateTime? expiresAt;
  final int accessCount;
  final bool isValid;

  ShareLink({
    required this.id,
    required this.token,
    required this.permission,
    this.expiresAt,
    required this.accessCount,
    required this.isValid,
  });

  factory ShareLink.fromJson(Map<String, dynamic> json) {
    return ShareLink(
      id: json['id'] as int,
      token: json['token'] as String,
      permission: json['permission'] as String,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      accessCount: json['access_count'] as int,
      isValid: json['is_valid'] as bool,
    );
  }
}

class DeletedFile {
  final int id;
  final MediaFile media;
  final DateTime deletedAt;
  final DateTime expiry;

  DeletedFile({
    required this.id,
    required this.media,
    required this.deletedAt,
    required this.expiry,
  });

  factory DeletedFile.fromJson(Map<String, dynamic> json) {
    return DeletedFile(
      id: json['id'] as int,
      media: MediaFile.fromJson(json['media'] as Map<String, dynamic>),
      deletedAt: DateTime.parse(json['deleted_at'] as String),
      expiry: DateTime.parse(json['expiry'] as String),
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiry);
}
