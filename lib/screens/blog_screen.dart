import 'package:flutter/material.dart';
import 'package:goatlas/screens/blog_information_screen.dart';
import 'package:goatlas/screens/create_blog_screen.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/blog_card.dart';
import '../models/blog_model.dart';
import '../components/blog_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utills/firebase_service.dart';

class BlogScreen extends StatelessWidget {
  const BlogScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, colorScheme),
            Expanded(
              // ─── StreamBuilder ดึงข้อมูล Firestore แบบ real-time ───
              child: StreamBuilder<List<BlogPost>>(
                stream: BlogService.instance.getBlogsStream(),
                builder: (context, snapshot) {
                  // กำลังโหลด
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // เกิด Error
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'),
                    );
                  }

                  final allPosts = snapshot.data ?? [];

                  // ไม่มีข้อมูล
                  if (allPosts.isEmpty) {
                    return const Center(
                      child: Text(
                        'ยังไม่มีบทความ\nกด + เพื่อเพิ่มบทความแรก!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    );
                  }

                  // เรียงตาม likes มาก → น้อย
                  final popularPosts = [...allPosts]
                    ..sort((a, b) => b.likes.compareTo(a.likes));

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildIntroSection(colorScheme),
                        if (popularPosts.isNotEmpty)
                          _buildPopularSection(
                            popularPosts,
                            colorScheme,
                            context,
                          ),
                        const SizedBox(height: 24),
                        _buildRecentSection(allPosts, context),
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // FAB → เปิดหน้าสร้างบทความ
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        tooltip: 'เพิ่มบทความ',
        shape: const CircleBorder(),
        onPressed: () async {
          final userInfo = await _getUserInfo(); // ดึงข้อมูล user
          if (!context.mounted) return;

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateBlogScreen(
                authorName: userInfo['name']!,
                authorAvatar: userInfo['avatar']!,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
  }

  Future<Map<String, String>> _getUserInfo() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final firebaseService = FirebaseService();
      final userData = await firebaseService.getUserData(user.uid);
      return {
        'name': userData?['username'] ?? user.displayName ?? 'ผู้ใช้',
        'avatar': userData?['photoUrl'] ?? user.photoURL ?? '',
      };
    }
    return {'name': 'ผู้ใช้', 'avatar': ''};
  }

  Widget _buildIntroSection(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'บทความแนะนำ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'เรื่องราวและประสบการณ์การเดินทางจากนักเดินทาง',
            style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSection(
    List<BlogPost> popularPosts,
    ColorScheme colorScheme,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'บทความยอดนิยม',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 420,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: popularPosts.length,
            itemBuilder: (context, index) {
              return BlogCard(
                post: popularPosts[index],
                width: 300,
                margin: EdgeInsets.only(
                  right: index < popularPosts.length - 1 ? 16 : 0,
                ),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        BlogInformationScreen(post: popularPosts[index]),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSection(List<BlogPost> posts, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'บทความล่าสุด',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: BlogCard(
                  post: posts[index],
                  width: double.infinity,
                  margin: EdgeInsets.zero,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlogInformationScreen(post: posts[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.article_outlined, color: colorScheme.onSurfaceVariant),
          Text(
            'บทความ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          Icon(Icons.search, color: colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
