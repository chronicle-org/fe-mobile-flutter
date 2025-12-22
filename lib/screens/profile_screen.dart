import 'package:flutter/material.dart';
import '../models/auth_response.dart';
import '../models/post.dart';
import '../services/user_service.dart';
import '../services/post_service.dart';
import '../services/api_service.dart';
import '../widgets/post_card.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  LoginResponse? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchUser();
  }

  Future<void> _fetchUser() async {
    try {
      final user = await UserService.getUserProfile(widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_user == null) return;
    final isFollowing =
        _user!.followers?.contains(ApiService.currentUserId) ?? false;
    final action = isFollowing ? 'unfollow' : 'follow';

    try {
      await UserService.toggleFollow(_user!.id, action);
      await _fetchUser(); // Refresh profile
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to $action: $e')));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _user == null) {
      return Scaffold(body: Center(child: Text('Error: $_error')));
    }

    final user = _user!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFollowing =
        user.followers?.contains(ApiService.currentUserId) ?? false;

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 100.0,
              pinned: false,
              flexibleSpace: FlexibleSpaceBar(
                background: user.bannerUrl != null
                    ? Image.network(user.bannerUrl!, fit: BoxFit.cover)
                    : Container(
                        color: isDark ? Colors.grey[800] : Colors.grey[300],
                        child: const Center(child: Icon(Icons.image, size: 50)),
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: user.pictureUrl != null
                              ? NetworkImage(user.pictureUrl!)
                              : null,
                          child: user.pictureUrl == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        if (ApiService.currentUserId != user.id)
                          ElevatedButton(
                            onPressed: _toggleFollow,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFollowing
                                  ? Colors.grey[300]
                                  : null,
                              foregroundColor: isFollowing
                                  ? Colors.black
                                  : null,
                            ),
                            child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '@${user.handle}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    if (user.profileDescription != null &&
                        user.profileDescription!.isNotEmpty)
                      Text(user.profileDescription!),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildStat('Followers', user.followersCount),
                        const SizedBox(width: 16),
                        _buildStat('Following', user.followingCount),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Posts'),
                    Tab(text: 'Followers'),
                    Tab(text: 'Following'),
                    Tab(text: 'Bookmarks'),
                  ],
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildPostsTab(),
            _buildFollowersTab(),
            _buildFollowingTab(),
            _buildBookmarksTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsTab() {
    return FutureBuilder<List<Post>>(
      future: PostService.getPostsByUserId(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text('No posts yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        );
      },
    );
  }

  Widget _buildFollowersTab() {
    return FutureBuilder<List<LoginResponse>>(
      future: UserService.getFollowers(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('No followers yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(
              backgroundImage: users[index].pictureUrl != null
                  ? NetworkImage(users[index].pictureUrl!)
                  : null,
              child: users[index].pictureUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(users[index].name),
            subtitle: Text('@${users[index].handle}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: users[index].id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildFollowingTab() {
    return FutureBuilder<List<LoginResponse>>(
      future: UserService.getFollowing(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final users = snapshot.data ?? [];
        if (users.isEmpty) {
          return const Center(child: Text('Not following anyone yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) => ListTile(
            leading: CircleAvatar(
              backgroundImage: users[index].pictureUrl != null
                  ? NetworkImage(users[index].pictureUrl!)
                  : null,
              child: users[index].pictureUrl == null
                  ? const Icon(Icons.person)
                  : null,
            ),
            title: Text(users[index].name),
            subtitle: Text('@${users[index].handle}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: users[index].id),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBookmarksTab() {
    return FutureBuilder<List<Post>>(
      future: UserService.getBookmarks(widget.userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        final posts = snapshot.data ?? [];
        if (posts.isEmpty) {
          return const Center(child: Text('No bookmarks yet'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: posts.length,
          itemBuilder: (context, index) => PostCard(post: posts[index]),
        );
      },
    );
  }

  Widget _buildStat(String label, int count) {
    return Row(
      children: [
        Text('$count', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
