import 'auth_response.dart';

class Comment {
  final int id;
  final int postId;
  final int userId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LoginResponse? user;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int? ?? 0,
      postId: json['post_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      content: json['content'] as String? ?? '',
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      user: json['user'] != null
          ? LoginResponse.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
