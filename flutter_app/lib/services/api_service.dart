import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class ApiService {
  final String baseUrl = const String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:8000');

  // Auth endpoints
  Future<bool> login(String username, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/login/');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final accessToken = data['access'] ?? '';
        final refreshToken = data['refresh'] ?? '';
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', accessToken);
        await prefs.setString('refresh_token', refreshToken);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    final url = Uri.parse('$baseUrl/api/auth/register/');
    try {
      final res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'password2': password,
        }),
      );
      if (res.statusCode == 201) {
        return await login(username, password);
      }
    } catch (_) {}
    return false;
  }

  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  Future<User?> getCurrentUser() async {
    final token = await getAccessToken();
    if (token == null) return null;
    final url = Uri.parse('$baseUrl/api/auth/me/');
    try {
      final res = await http.get(url, headers: {'Authorization': 'Bearer $token'});
      if (res.statusCode == 200) {
        return User.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await getAccessToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Client endpoints
  Future<List<Client>> getClients() async {
    final url = Uri.parse('$baseUrl/api/clients/');
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((c) => Client.fromJson(c as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<Client?> createClient(String name) async {
    final url = Uri.parse('$baseUrl/api/clients/');
    try {
      final headers = await _getHeaders();
      final res = await http.post(url, headers: headers, body: jsonEncode({'name': name}));
      if (res.statusCode == 201) {
        return Client.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  // Project endpoints
  Future<List<Project>> getProjects() async {
    final url = Uri.parse('$baseUrl/api/projects/');
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((p) => Project.fromJson(p as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<Project?> createProject(int clientId, String name) async {
    final url = Uri.parse('$baseUrl/api/projects/');
    try {
      final headers = await _getHeaders();
      final res = await http.post(url, headers: headers, body: jsonEncode({'client': clientId, 'name': name}));
      if (res.statusCode == 201) {
        return Project.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  // Media endpoints
  Future<List<MediaFile>> getMedia() async {
    final url = Uri.parse('$baseUrl/api/media/');
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((m) => MediaFile.fromJson(m as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<MediaFile?> getMediaDetail(int id) async {
    final url = Uri.parse('$baseUrl/api/media/$id/');
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        return MediaFile.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  Future<MediaFile?> uploadMedia(int projectId, String filePath, String mediaType, {String status = 'raw'}) async {
    final url = Uri.parse('$baseUrl/api/media/');
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      request.fields['project'] = projectId.toString();
      request.fields['media_type'] = mediaType;
      request.fields['status'] = status;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        return MediaFile.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return null;
  }

  Future<bool> softDeleteMedia(int id) async {
    final url = Uri.parse('$baseUrl/api/media/$id/');
    try {
      final headers = await _getHeaders();
      final res = await http.delete(url, headers: headers);
      return res.statusCode == 204;
    } catch (_) {}
    return false;
  }

  Future<MediaFile?> restoreMedia(int id) async {
    final url = Uri.parse('$baseUrl/api/media/$id/restore/');
    try {
      final headers = await _getHeaders();
      final res = await http.post(url, headers: headers);
      if (res.statusCode == 200) {
        return MediaFile.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  // Version endpoints
  Future<List<FileVersion>> getVersions(int mediaId) async {
    final url = Uri.parse('$baseUrl/api/media/$mediaId/versions/');
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((v) => FileVersion.fromJson(v as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<FileVersion?> createVersion(int mediaId, String filePath, {String? note}) async {
    final url = Uri.parse('$baseUrl/api/media/$mediaId/create_version/');
    try {
      final headers = await _getHeaders();
      final request = http.MultipartRequest('POST', url);
      request.headers.addAll(headers);
      if (note != null) request.fields['note'] = note;
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 201) {
        return FileVersion.fromJson(jsonDecode(response.body));
      }
    } catch (_) {}
    return null;
  }

  // Share endpoints
  Future<List<ShareLink>> getShareLinks(int mediaId) async {
    final url = Uri.parse('$baseUrl/api/media/$mediaId/shares/');
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((s) => ShareLink.fromJson(s as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<ShareLink?> createShareLink(int mediaId, {String permission = 'view', int expiresInDays = 7}) async {
    final url = Uri.parse('$baseUrl/api/media/$mediaId/create_share/');
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        url,
        headers: headers,
        body: jsonEncode({'permission': permission, 'expires_in_days': expiresInDays}),
      );
      if (res.statusCode == 201) {
        return ShareLink.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}
    return null;
  }

  Future<bool> deleteShareLink(int id) async {
    final url = Uri.parse('$baseUrl/api/shares/$id/');
    try {
      final headers = await _getHeaders();
      final res = await http.delete(url, headers: headers);
      return res.statusCode == 204;
    } catch (_) {}
    return false;
  }

  // Recovery Vault
  Future<List<DeletedFile>> getDeletedFiles() async {
    final url = Uri.parse('$baseUrl/api/deleted/');
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final List<dynamic> data = jsonDecode(res.body);
        return data.map((d) => DeletedFile.fromJson(d as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }

  // Duplicate detection
  Future<List<MediaFile>> getDuplicates(int mediaId) async {
    final url = Uri.parse('$baseUrl/api/media/$mediaId/duplicates/');
    try {
      final headers = await _getHeaders();
      final res = await http.get(url, headers: headers);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<dynamic> dupes = data['exact_duplicates'] ?? [];
        return dupes.map((d) => MediaFile.fromJson(d as Map<String, dynamic>)).toList();
      }
    } catch (_) {}
    return [];
  }
}
