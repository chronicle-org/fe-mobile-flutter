import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post.dart';
import 'api_service.dart';

class PostService {
  static Future<Post> getOnePost(int id) async {
    final uri = Uri.parse('${ApiService.baseUrl}/post/$id');
    final response = await http.get(uri, headers: ApiService.headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Post.fromJson(body['content']);
    } else {
      throw Exception('Failed to load post');
    }
  }

  static Future<List<Post>> getAllPosts({
    int page = 1,
    int limit = 10,
    String search = "",
  }) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/post?page=$page&limit=$limit&search=$search',
    );

    final response = await http.get(uri, headers: ApiService.headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final content = body['content'];
      if (content != null && content['data'] != null) {
        final List<dynamic> data = content['data'];
        return data.map((e) => Post.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  static Future<List<Post>> getPostsByUserId(
    int userId, {
    int page = 1,
    int limit = 10,
    String search = "",
  }) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/post/user/$userId?page=$page&limit=$limit&search=$search',
    );

    final response = await http.get(uri, headers: ApiService.headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final content = body['content'];
      if (content != null && content['data'] != null) {
        final List<dynamic> data = content['data'];
        return data.map((e) => Post.fromJson(e)).toList();
      }
      return [];
    } else {
      throw Exception('Failed to load user posts: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>?> toggleInteraction(
    int postId,
    String actionType,
  ) async {
    final uri = Uri.parse(
      '${ApiService.baseUrl}/post/interaction/$actionType/$postId',
    );
    final response = await http.put(uri, headers: ApiService.headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return body['content'];
    } else {
      throw Exception('Interaction failed: ${response.statusCode}');
    }
  }

  static Future<Post> createPost(Map<String, dynamic> data) async {
    final uri = Uri.parse('${ApiService.baseUrl}/post');
    final response = await http.post(
      uri,
      headers: ApiService.headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return Post.fromJson(body['content']);
    } else {
      throw Exception('Failed to create post: ${response.statusCode}');
    }
  }

  static Future<Post> updatePost(int id, Map<String, dynamic> data) async {
    final uri = Uri.parse('${ApiService.baseUrl}/post/$id');
    final response = await http.put(
      uri,
      headers: ApiService.headers,
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Post.fromJson(body['content']);
    } else {
      throw Exception('Failed to update post: ${response.statusCode}');
    }
  }

  static Future<void> deletePost(int id) async {
    final uri = Uri.parse('${ApiService.baseUrl}/post/$id');
    final response = await http.delete(uri, headers: ApiService.headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post: ${response.statusCode}');
    }
  }
}
