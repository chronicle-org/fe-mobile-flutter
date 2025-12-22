import 'package:flutter/material.dart';
import '../models/comment.dart';
import '../services/comment_service.dart';
import '../services/api_service.dart';
import 'package:intl/intl.dart';

class CommentSection extends StatefulWidget {
  final int postId;

  const CommentSection({super.key, required this.postId});

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final _commentController = TextEditingController();
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    try {
      final comments = await CommentService.getCommentsByPostId(widget.postId);
      setState(() {
        _comments = comments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      await CommentService.createComment(widget.postId, content);
      _commentController.clear();
      await _fetchComments(); // Refresh list
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to post comment: $e')));
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text(
            'Comments (${_comments.length})',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                ),
              ),
              const SizedBox(width: 8),
              if (_isSubmitting)
                const CircularProgressIndicator()
              else
                IconButton(
                  onPressed: _submitComment,
                  icon: const Icon(Icons.send),
                  color: Theme.of(context).colorScheme.primary,
                ),
            ],
          ),
        ),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_comments.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No comments yet. Be the first to comment!'),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _comments.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (_, index) {
              final comment = _comments[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: comment.user?.pictureUrl != null
                      ? NetworkImage(comment.user!.pictureUrl!)
                      : null,
                  child: comment.user?.pictureUrl == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.user?.name ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat.yMMMd().format(comment.createdAt),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(comment.content),
                ),
                trailing: comment.userId == ApiService.currentUserId
                    ? IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          try {
                            await CommentService.deleteComment(comment.id);
                            await _fetchComments();
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Failed to delete: $e')),
                              );
                            }
                          }
                        },
                      )
                    : null,
              );
            },
          ),
      ],
    );
  }
}
