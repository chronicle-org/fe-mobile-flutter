class LoginResponse {
  final int id;
  final String name;
  final String email;
  final DateTime createdAt;
  final String? pictureUrl;
  final String? bannerUrl;
  final String handle;
  final String accessToken;
  final String? profileDescription;
  final String? tags;
  final List<int>? following;
  final int followingCount;
  final List<int>? followers;
  final int followersCount;
  final List<int>? likes;
  final int likesCount;
  final List<int>? bookmarks;
  final int bookmarksCount;

  const LoginResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.handle,
    required this.accessToken,
    required this.followingCount,
    required this.followersCount,
    required this.likesCount,
    required this.bookmarksCount,
    this.pictureUrl,
    this.bannerUrl,
    this.profileDescription,
    this.tags,
    this.following,
    this.followers,
    this.likes,
    this.bookmarks,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      pictureUrl: json['picture_url'] as String?,
      bannerUrl: json['banner_url'] as String?,
      handle: json['handle'] as String? ?? '',
      accessToken: json['access_token'] as String? ?? '',
      profileDescription: json['profile_description'] as String?,
      tags: json['tags'] as String?,
      following: (json['following'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      followingCount: json['following_count'] as int? ?? 0,
      followers: (json['followers'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      followersCount: json['followers_count'] as int? ?? 0,
      likes: (json['likes'] as List<dynamic>?)?.map((e) => e as int).toList(),
      likesCount: json['likes_count'] as int? ?? 0,
      bookmarks: (json['bookmarks'] as List<dynamic>?)
          ?.map((e) => e as int)
          .toList(),
      bookmarksCount: json['bookmarks_count'] as int? ?? 0,
    );
  }
}
