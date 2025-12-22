import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/comment.dart';
import 'api_service.dart';

class CommentService {
  static Future<List<Comment>> getCommentsByPostId(int postId) async {
    final uri = Uri.parse('${ApiService.baseUrl}/comment/$postId');
    final response = await http.get(uri, headers: ApiService.headers);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['content'] ?? [];
      return data.map((e) => Comment.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  static Future<Comment> createComment(int postId, String content) async {
    final uri = Uri.parse('${ApiService.baseUrl}/comment');
    final response = await http.post(
      uri,
      headers: ApiService.headers,
      body: jsonEncode({'post_id': postId, 'content': content}),
    );

    if (response.statusCode == 201) {
      final body = jsonDecode(response.body);
      return Comment.fromJson(body['content']);
    } else {
      throw Exception('Failed to create comment: ${response.statusCode}');
    }
  }

  static Future<void> deleteComment(int id) async {
    final uri = Uri.parse('${ApiService.baseUrl}/comment/$id');
    final response = await http.delete(uri, headers: ApiService.headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete comment: ${response.statusCode}');
    }
  }
}
