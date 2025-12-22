import 'package:flutter_html/flutter_html.dart';
import 'package:flutter/material.dart';
import '../models/post.dart';
import 'package:intl/intl.dart';
import '../screens/post_detail_screen.dart';
import '../screens/profile_screen.dart';
import '../services/api_service.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback? onTap;

  const PostCard({super.key, required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap:
            onTap ??
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PostDetailScreen(postId: post.id),
                ),
              );
            },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            if (post.thumbnailUrl.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.network(
                  post.thumbnailUrl,
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 140,
                      color: Colors.grey.shade200,
                      child: const Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tags
                  if (post.tags.isNotEmpty)
                    Text(
                      post.tags.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                  // Title (HTML)
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
                        fontSize: FontSize(
                          Theme.of(context).textTheme.titleLarge?.fontSize ??
                              20,
                        ),
                        fontWeight: FontWeight.bold,
                        margin: Margins.all(0),
                        lineHeight: LineHeight.normal,
                      ),
                      "p": Style(
                        margin: Margins.all(0),
                        fontSize: FontSize(
                          Theme.of(context).textTheme.titleLarge?.fontSize ??
                              20,
                        ),
                        fontWeight: FontWeight.bold,
                        lineHeight: LineHeight.normal,
                      ),
                    },
                  ),
                  const SizedBox(height: 4),
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
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                        margin: Margins.all(0),
                        maxLines: 2,
                        textOverflow: TextOverflow.ellipsis,
                      ),
                    },
                  ),
                  const SizedBox(height: 8),
                  const SizedBox(height: 12),
                  // Stats Row
                  Row(
                    children: [
                      Icon(
                        post.likes.contains(ApiService.currentUserId)
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 14,
                        color: post.likes.contains(ApiService.currentUserId)
                            ? Colors.red
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likesCount}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        post.bookmarks.contains(ApiService.currentUserId)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        size: 14,
                        color: post.bookmarks.contains(ApiService.currentUserId)
                            ? Colors.deepPurple
                            : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.bookmarksCount}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.comment_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentCount}',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Footer (Author + Date)
                  GestureDetector(
                    onTap: () {
                      if (post.user != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProfileScreen(userId: post.user!.id),
                          ),
                        );
                      }
                    },
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: post.user?.pictureUrl != null
                              ? NetworkImage(post.user!.pictureUrl!)
                              : null,
                          child: post.user?.pictureUrl == null
                              ? const Icon(Icons.person, size: 24)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            post.user?.name ?? 'Unknown',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat.yMMMd().format(post.createdAt),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
