import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_response.dart';
import '../models/post.dart';
import 'api_service.dart';

class UserService {
  static Future<LoginResponse> getUserProfile(int id) async {
    final uri = Uri.parse('${ApiService.baseUrl}/user/$id');
    final response = await http.get(uri, headers: ApiService.headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final content = body['content'];
      if (content == null) {
        throw Exception('User profile not found in response');
      }
      return LoginResponse.fromJson(content);
    } else {
      throw Exception(
        'Failed to load user profile: ${response.statusCode} - ${response.body}',
      );
    }
  }

  static Future<List<LoginResponse>> getFollowers(int id) async {
    final uri = Uri.parse('${ApiService.baseUrl}/user/followers/$id');
    final response = await http.get(uri, headers: ApiService.headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['content'] ?? [];
      return data.map((e) => LoginResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load followers');
    }
  }

  static Future<List<LoginResponse>> getFollowing(int id) async {
    final uri = Uri.parse('${ApiService.baseUrl}/user/following/$id');
    final response = await http.get(uri, headers: ApiService.headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['content'] ?? [];
      return data.map((e) => LoginResponse.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load following');
    }
  }

  static Future<List<Post>> getBookmarks(int id) async {
    final uri = Uri.parse('${ApiService.baseUrl}/user/bookmarks/$id');
    final response = await http.get(uri, headers: ApiService.headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['content'] ?? [];
      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load bookmarks');
    }
  }

  static Future<List<Post>> getLikes(int id) async {
    final uri = Uri.parse('${ApiService.baseUrl}/user/likes/$id');
    final response = await http.get(uri, headers: ApiService.headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['content'] ?? [];
      return data.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load likes');
    }
  }

  static Future<LoginResponse> toggleFollow(
    int userId,
    String actionType,
  ) async {
    final uri = Uri.parse('${ApiService.baseUrl}/user/$actionType/$userId');
    final response = await http.post(uri, headers: ApiService.headers);

    if (response.statusCode == 201 || response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return LoginResponse.fromJson(body['content']);
    } else {
      throw Exception('Failed to $actionType user: ${response.statusCode}');
    }
  }
}
