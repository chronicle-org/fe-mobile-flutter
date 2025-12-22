import 'package:flutter/material.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';

class HomeScreen extends StatefulWidget {
  final String searchQuery;

  const HomeScreen({super.key, this.searchQuery = ''});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Post> _posts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      _fetchPosts();
    }
  }

  Future<void> _fetchPosts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final posts = await PostService.getAllPosts(search: widget.searchQuery);
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Error: $_error'),
            ElevatedButton(onPressed: _fetchPosts, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_posts.isEmpty) {
      return const Center(child: Text('No posts found.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchPosts,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return PostCard(post: post);
        },
      ),
    );
  }
}
