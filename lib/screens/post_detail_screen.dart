import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/comment_section.dart';
import '../screens/edit_post_screen.dart';
import 'package:chronicle/services/api_service.dart';

class PostDetailScreen extends StatefulWidget {
  final int postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  Post? _post;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPost();
  }

  Future<void> _fetchPost() async {
    try {
      final post = await PostService.getOnePost(widget.postId);
      setState(() {
        _post = post;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_post == null) return;
    final isLiked = _post!.likes.contains(ApiService.currentUserId);
    final action = isLiked ? 'unlike' : 'like';

    try {
      await PostService.toggleInteraction(_post!.id, action);
      // Refresh post to get updated counts and likes list
      await _fetchPost();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to $action: $e')));
      }
    }
  }

  Future<void> _toggleBookmark() async {
    if (_post == null) return;
    final isBookmarked = _post!.bookmarks.contains(ApiService.currentUserId);
    final action = isBookmarked ? 'unbookmark' : 'bookmark';

    try {
      await PostService.toggleInteraction(_post!.id, action);
      // Refresh post to get updated bookmarks list
      await _fetchPost();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to $action: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _post == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $_error')),
      );
    }

    final post = _post!;
    final currentUserId = ApiService.currentUserId;
    final isLiked = post.likes.contains(currentUserId);
    final isBookmarked = post.bookmarks.contains(currentUserId);

    return Scaffold(
      appBar: AppBar(
        actions: [
          if (post.userId == ApiService.currentUserId)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostScreen(post: post),
                  ),
                );
                if (result == true) {
                  _fetchPost(); // Refresh if edited
                }
              },
              tooltip: 'Edit Post',
            ),
          IconButton(
            icon: Icon(
              isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: isBookmarked ? Colors.deepPurple : null,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Handle share
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (post.thumbnailUrl.isNotEmpty)
              Image.network(
                post.thumbnailUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: double.infinity,
                  height: 200,
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, size: 50),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title (HTML)
                  Html(
                    data:
                        '<div class="ql-bubble"><div class="ql-editor">${post.title}</div></div>',
                    style: {
                      ".ql-editor": Style(
                        margin: Margins.all(0),
                        padding: HtmlPaddings.all(0),
                      ),
                      "h1": Style(
                        fontSize: FontSize(28),
                        fontWeight: FontWeight.bold,
                        margin: Margins.all(0),
                        lineHeight: LineHeight.normal,
                      ),
                      "p": Style(
                        margin: Margins.all(0),
                        fontSize: FontSize(28),
                        fontWeight: FontWeight.bold,
                        lineHeight: LineHeight.normal,
                      ),
                    },
                  ),
                  const SizedBox(height: 8),
                  // Subtitle (HTML)
                  Html(
                    data:
                        '<div class="ql-bubble"><div class="ql-editor">${post.subTitle}</div></div>',
                    style: {
                      ".ql-editor": Style(
                        margin: Margins.all(0),
                        padding: HtmlPaddings.all(0),
                      ),
                      "p": Style(
                        color: Colors.grey,
                        fontSize: FontSize(18),
                        margin: Margins.all(0),
                      ),
                    },
                  ),
                  const SizedBox(height: 16),

                  // Author Row
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: post.user?.pictureUrl != null
                            ? NetworkImage(post.user!.pictureUrl!)
                            : null,
                        child: post.user?.pictureUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.user?.name ?? 'Unknown',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            DateFormat.yMMMd().format(post.createdAt),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Stats Row
                  Row(
                    children: [
                      Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                      Icon(Icons.comment, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Divider
                  const Divider(),

                  const SizedBox(height: 24),

                  // Body Content
                  Html(
                    data:
                        '<div class="ql-bubble"><div class="ql-editor">${post.content}</div></div>',
                    style: {
                      "body": Style(
                        margin: Margins.all(0),
                        padding: HtmlPaddings.all(0),
                        fontSize: FontSize(16),
                        lineHeight: LineHeight.em(1.6),
                      ),
                      ".ql-editor": Style(
                        margin: Margins.all(0),
                        padding: HtmlPaddings.all(0),
                      ),
                      "p": Style(margin: Margins.only(bottom: 16)),
                      "img": Style(
                        width: Width(100, Unit.percent),
                        height: Height.auto(),
                        margin: Margins.symmetric(vertical: 10),
                      ),
                    },
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  CommentSection(postId: post.id),
                  const SizedBox(height: 100), // Extra space for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleLike,
        backgroundColor: isLiked ? Colors.red : null,
        child: Icon(
          isLiked ? Icons.favorite : Icons.favorite_border,
          color: isLiked ? Colors.white : null,
        ),
      ),
    );
  }
}
