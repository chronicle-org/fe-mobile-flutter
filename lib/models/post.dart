import 'auth_response.dart';

class Post {
  final int id;
  final int userId;
  final String title;
  final String subTitle;
  final String content;
  final String thumbnailUrl;
  final int commentCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool visibility;
  final String tags;
  final int bookmarksCount;
  final List<int> bookmarks;
  final int shareCount;
  final int viewCount;
  final int likesCount;
  final List<int> likes;
  final LoginResponse? user; // Using LoginResponse as a proxy for User for now

  Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.subTitle,
    required this.content,
    required this.thumbnailUrl,
    required this.commentCount,
    required this.createdAt,
    required this.updatedAt,
    required this.visibility,
    required this.tags,
    required this.bookmarksCount,
    required this.bookmarks,
    required this.shareCount,
    required this.viewCount,
    required this.likesCount,
    required this.likes,
    this.user,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      subTitle: json['sub_title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String? ?? '',
      commentCount: json['comment_count'] as int? ?? 0,
      createdAt: DateTime.parse(
        json['created_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updated_at'] as String? ?? DateTime.now().toIso8601String(),
      ),
      visibility: json['visibility'] as bool? ?? true,
      tags: json['tags'] as String? ?? '',
      bookmarksCount: json['bookmarks_count'] as int? ?? 0,
      bookmarks:
          (json['bookmarks'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toList() ??
          [],
      shareCount: json['share_count'] as int? ?? 0,
      viewCount: json['view_count'] as int? ?? 0,
      likesCount: json['likes_count'] as int? ?? 0,
      likes:
          (json['likes'] as List<dynamic>?)?.map((e) => e as int).toList() ??
          [],
      user: json['user'] != null
          ? LoginResponse.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }
}
