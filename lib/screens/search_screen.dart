import 'package:flutter/material.dart';
import '../services/post_service.dart';
import '../widgets/post_card.dart';
import '../models/post.dart';
import 'package:chronicle/screens/post_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Post> _posts = [];
  bool _isLoading = false;
  String _searchQuery = '';
  // Debounce could be added here, but for now we search on submit

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });

    try {
      // Reusing getAllPosts but filtering by search query implies we might not have a dedicated search endpoint yet,
      // but based on previous knowledge getAllPosts accepts a search param.
      // Assuming PostService.getAllPosts(search: query) works.
      final posts = await PostService.getAllPosts(search: query);
      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        // Handle error (maybe show snackbar)
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search posts...',
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                // Optionally clear results too
                setState(() {
                  _posts = [];
                  _searchQuery = '';
                });
              },
            ),
          ),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _posts.isEmpty && _searchQuery.isNotEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No results found for "$_searchQuery"',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          : _posts.isEmpty && _searchQuery.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Type to search', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _posts.length,
              itemBuilder: (context, index) {
                final post = _posts[index];
                return PostCard(
                  post: post,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailScreen(postId: post.id),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
