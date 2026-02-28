import 'package:flutter/material.dart';
import 'package:goatlas/screens/blog_information_screen.dart';
import 'package:goatlas/screens/create_blog_screen.dart';
import '../components/custom_bottom_nav_bar.dart';
import '../components/blog_card.dart';
import '../models/blog_model.dart';

class BlogScreen extends StatefulWidget {
  const BlogScreen({super.key});

  @override
  State<BlogScreen> createState() => _BlogScreenState();
}

class _BlogScreenState extends State<BlogScreen> {
  final List<BlogPost> _userBlogPosts = [];
  late final List<BlogPost> _sampleBlogPosts;

  @override
  void initState() {
    super.initState();
    _sampleBlogPosts = _getSampleBlogPosts();
  }

  List<BlogPost> _getSampleBlogPosts() {
    return [
      BlogPost(
        id: '1',
        title: 'เที่ยวญี่ปุ่นครั้งแรก ต้องรู้อะไรบ้าง?',
        content: '...',
        authorName: 'สมชาย ใจดี',
        authorAvatar: '',
        coverImage:
            'https://imgcp.aacdn.jp/img-a/1440/auto/global-aaj-front/article/2017/06/595048184fa06_5950474045019_1189093891.jpg',
        publishedDate: DateTime.now().subtract(const Duration(hours: 5)),
        readTime: 8,
        likes: 245,
        comments: 32,
        tags: ['เที่ยวญี่ปุ่น', 'ครั้งแรก'],
      ),
      BlogPost(
        id: '2',
        title: '10 ที่เที่ยวต้องห้ามพลาดในโตเกียว',
        content: '...',
        authorName: 'ปรียา สุขสันต์',
        authorAvatar: '',
        coverImage:
            'https://imgcp.aacdn.jp/img-a/1440/auto/global-aaj-front/article/2017/06/595048184fa06_5950474045019_1189093891.jpg',
        publishedDate: DateTime.now().subtract(const Duration(days: 2)),
        readTime: 12,
        likes: 189,
        comments: 25,
        tags: ['โตเกียว', 'ที่เที่ยว'],
      ),
      BlogPost(
        id: '3',
        title: 'คู่มือกินอาหารญี่ปุ่นฉบับมือใหม่',
        content: '...',
        authorName: 'วิชัย รักเที่ยว',
        authorAvatar: '',
        coverImage:
            'https://imgcp.aacdn.jp/img-a/1440/auto/global-aaj-front/article/2017/06/595048184fa06_5950474045019_1189093891.jpg',
        publishedDate: DateTime.now().subtract(const Duration(days: 5)),
        readTime: 10,
        likes: 312,
        comments: 48,
        tags: ['อาหาร', 'คู่มือ'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    /// รวมทั้งหมด
    final allPosts = [..._userBlogPosts, ..._sampleBlogPosts];

    /// เรียงตาม likes มาก -> น้อย
    final popularPosts = [...allPosts]
      ..sort((a, b) => b.likes.compareTo(a.likes));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, colorScheme),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildIntroSection(colorScheme),

                    /// ===== POPULAR =====
                    if (popularPosts.isNotEmpty)
                      _buildPopularSection(popularPosts, colorScheme),

                    const SizedBox(height: 24),

                    /// ===== RECENT =====
                    _buildRecentSection(allPosts),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      /// FAB
      floatingActionButton: FloatingActionButton(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        tooltip: "เพิ่มบทความ",
        shape: CircleBorder(),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateBlogScreen(
                authorName: 'ชื่อผู้ใช้',
                authorAvatar: '',
              ),
            ),
          );

          if (result != null && result is BlogPost) {
            setState(() {
              _userBlogPosts.insert(0, result);
            });
          }
        },
        child: const Icon(Icons.add),
      ),

      bottomNavigationBar: const CustomBottomNavBar(currentIndex: 2),
    );
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
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'บทความยอดนิยม',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 400,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: popularPosts.length,
              itemBuilder: (context, index) {
                return BlogCard(
                  post: popularPosts[index],
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BlogInformationScreen(post: popularPosts[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection(List<BlogPost> posts) {
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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            BlogInformationScreen(post: posts[index]),
                      ),
                    );
                  },
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
